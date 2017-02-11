defmodule Ex338.Championship.Store do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{Championship, Repo}

  def get_all() do
    Championship
    |> Championship.preload_assocs
    |> Championship.earliest_first
    |> Repo.all
  end

  def get_championship_by_league(id, league_id) do
    Championship
    |> Championship.preload_assocs_by_league(league_id)
    |> Repo.get!(id)
    |> preload_events_by_league(league_id)
  end

  def preload_events_by_league(championship, league_id) do
    events =
      Championship
      |> Championship.preload_assocs_by_league(league_id)
      |> Championship.earliest_first

    Repo.preload(championship, events: events)
  end

  def get_slot_standings(overall_id, league_id) do
    Championship
    |> Championship.sum_slot_points(overall_id, league_id)
    |> Repo.all
    |> sort_by_points
  end

  defp sort_by_points(slot_standings) do
    Enum.sort(slot_standings, &(&1.points >= &2.points))
  end
end
