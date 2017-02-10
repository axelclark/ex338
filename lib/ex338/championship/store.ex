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
  end
end
