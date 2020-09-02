defmodule Ex338.DraftQueues do
  @moduledoc false

  import Ecto.Query, only: [limit: 2]

  alias Ex338.{Repo, DraftQueues, DraftQueues.DraftQueue, FantasyTeams}

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

  def get_league_queues(fantasy_league_id) do
    DraftQueue
    |> DraftQueue.by_league(fantasy_league_id)
    |> DraftQueue.only_pending()
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
