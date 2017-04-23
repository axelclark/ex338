defmodule Ex338.SportsLeague.Store do
  @moduledoc false

  alias Ex338.{SportsLeague, Repo}

  def league_abbrevs(fantasy_league_id) do
    SportsLeague
    |> SportsLeague.for_league(fantasy_league_id)
    |> SportsLeague.abbrev_a_to_z
    |> SportsLeague.select_abbrev
    |> Repo.all
  end

  def league_abbrevs() do
    SportsLeague
    |> SportsLeague.abbrev_a_to_z
    |> SportsLeague.select_abbrev
    |> Repo.all
  end
end
