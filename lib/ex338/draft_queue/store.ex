defmodule Ex338.DraftQueue.Store do
  @moduledoc false

  import Ecto.Query, only: [limit: 2]

  alias Ex338.{Repo, DraftQueue, FantasyTeam}

  def create_draft_queue(attrs \\ %{}) do
    updated_attrs = add_order_from_queue_count(attrs)

    %DraftQueue{}
    |> DraftQueue.changeset(updated_attrs)
    |> Repo.insert()
  end

  def get_league_queues(fantasy_league_id) do
    DraftQueue
    |> DraftQueue.by_league(fantasy_league_id)
    |> DraftQueue.only_pending()
    |> Repo.all()
  end

  def get_top_queue(team_id, sport_id) do
    DraftQueue
    |> DraftQueue.by_team(team_id)
    |> DraftQueue.by_sport(sport_id)
    |> DraftQueue.only_pending()
    |> DraftQueue.ordered()
    |> limit(1)
    |> Repo.one()
  end

  def reorder_for_league(fantasy_league_id) do
    fantasy_league_id
    |> get_league_queues()
    |> DraftQueue.Admin.reorder_for_league()
    |> Repo.transaction()
  end

  ## Helpers

  ## create_draft_queue

  defp add_order_from_queue_count(%{"order" => _order} = attrs), do: attrs

  defp add_order_from_queue_count(%{"fantasy_team_id" => team_id} = attrs) do
    queue_count = FantasyTeam.Store.count_pending_draft_queues(team_id)

    Map.put(attrs, "order", queue_count + 1)
  end

  defp add_order_from_queue_count(attrs), do: attrs
end
