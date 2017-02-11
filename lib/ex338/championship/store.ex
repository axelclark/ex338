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
end
