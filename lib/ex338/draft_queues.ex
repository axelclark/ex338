defmodule Ex338.DraftQueues do
  @moduledoc false

  import Ecto.Query, only: [limit: 2]

  alias Ecto.Multi
  alias Ex338.DraftQueues
  alias Ex338.DraftQueues.DraftQueue
  alias Ex338.FantasyTeams
  alias Ex338.Repo

  def archive_pending_queues(fantasy_league_id) do
    DraftQueue
    |> DraftQueue.by_league(fantasy_league_id)
    |> DraftQueue.only_pending()
    |> Repo.update_all(set: [status: :archived])
  end

  def create_draft_queue(attrs \\ %{}) do
    updated_attrs = add_order_from_queue_count(attrs)

    %DraftQueue{}
    |> DraftQueue.changeset(updated_attrs)
    |> Repo.insert()
  end

  def get_draft_queue!(queue_id) do
    DraftQueue
    |> DraftQueue.preload_assocs()
    |> Repo.get!(queue_id)
  end

  @doc """
  Fetches a draft queue, or nil if it doesn't exist.

  Accepts untrusted ids and returns nil for anything that isn't a valid integer
  id, rather than raising `Ecto.Query.CastError`, since API/MCP callers pass
  client-supplied values.
  """
  def get_draft_queue(queue_id) do
    case cast_id(queue_id) do
      {:ok, id} -> DraftQueue |> DraftQueue.preload_assocs() |> Repo.get(id)
      :error -> nil
    end
  end

  @doc """
  Rewrites a team's pending draft queue to the order given by `ordered_queue_ids`.

  The list must name every pending queue for the team exactly once. A partial
  list is rejected rather than applied, because renumbering only some entries
  would leave the rest holding duplicate positions — and `order` is what
  autodraft reads to decide who to take next.

  Returns `{:ok, [%DraftQueue{}]}` in the new order, `{:error, :queue_ids_mismatch}`
  if the ids don't match the team's pending queues.
  """
  def reorder_for_team(team_id, ordered_queue_ids) do
    pending_ids = team_id |> list_team_queues() |> Enum.map(& &1.id)

    if Enum.sort(pending_ids) == Enum.sort(ordered_queue_ids) do
      ordered_queue_ids
      |> Enum.with_index(1)
      |> Enum.reduce(Multi.new(), &set_queue_order/2)
      |> Repo.transaction()

      {:ok, list_team_queues(team_id)}
    else
      {:error, :queue_ids_mismatch}
    end
  end

  defp set_queue_order({queue_id, order}, multi) do
    update_query = DraftQueue |> DraftQueue.by_id(queue_id) |> DraftQueue.update_order(order)

    Multi.update_all(multi, {:queue, queue_id}, update_query, [])
  end

  @doc """
  Deletes a draft queue and closes the gap it leaves in its team's order.

  The remaining entries are renumbered from 1 in the same transaction; leaving a
  hole would be harmless for display but not for the `order` autodraft reads.
  """
  def delete_draft_queue(%DraftQueue{} = draft_queue) do
    Multi.new()
    |> Multi.delete(:draft_queue, draft_queue)
    |> Multi.merge(fn _changes ->
      draft_queue.fantasy_team_id
      |> list_team_queues()
      |> DraftQueues.Admin.reorder_for_league()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{draft_queue: deleted}} -> {:ok, deleted}
      {:error, _operation, reason, _changes} -> {:error, reason}
    end
  end

  defp cast_id(id) when is_integer(id), do: {:ok, id}

  defp cast_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, ""} -> {:ok, int}
      _ -> :error
    end
  end

  defp cast_id(_id), do: :error

  def get_league_queues(fantasy_league_id) do
    DraftQueue
    |> DraftQueue.by_league(fantasy_league_id)
    |> DraftQueue.only_pending()
    |> Repo.all()
  end

  def list_team_queues(team_id) do
    DraftQueue
    |> DraftQueue.by_team(team_id)
    |> DraftQueue.only_pending()
    |> DraftQueue.ordered()
    |> DraftQueue.preload_assocs()
    |> Repo.all()
  end

  def get_top_queue(team_id) do
    DraftQueue
    |> DraftQueue.by_team(team_id)
    |> DraftQueue.preload_assocs()
    |> DraftQueue.only_pending()
    |> DraftQueue.ordered()
    |> limit(1)
    |> Repo.one()
  end

  def get_top_queue_by_sport(team_id, sport_id) do
    DraftQueue
    |> DraftQueue.by_team(team_id)
    |> DraftQueue.by_sport(sport_id)
    |> DraftQueue.preload_assocs()
    |> DraftQueue.only_pending()
    |> DraftQueue.ordered()
    |> limit(1)
    |> Repo.one()
  end

  def reorder_for_league(fantasy_league_id) do
    fantasy_league_id
    |> get_league_queues()
    |> DraftQueues.Admin.reorder_for_league()
    |> Repo.transaction()
  end

  ## Helpers

  ## create_draft_queue

  defp add_order_from_queue_count(%{"order" => _order} = attrs), do: attrs

  defp add_order_from_queue_count(%{"fantasy_team_id" => team_id} = attrs) do
    queue_count = FantasyTeams.count_pending_draft_queues(team_id)

    Map.put(attrs, "order", queue_count + 1)
  end

  defp add_order_from_queue_count(attrs), do: attrs
end
