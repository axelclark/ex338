defmodule Ex338.RosterPosition.Store do
  @moduledoc false

  alias Ex338.{RosterPosition, Repo, SportsLeague}

  def positions_for_draft(fantasy_league_id, championship_id) do
    RosterPosition
    |> RosterPosition.all_active
    |> RosterPosition.all_draft_picks
    |> RosterPosition.from_league(fantasy_league_id)
    |> RosterPosition.sport_from_champ(championship_id)
    |> RosterPosition.preload_assocs
    |> Repo.all
  end

  def positions(fantasy_league_id) do
    primary_positions = SportsLeague.Store.league_abbrevs(fantasy_league_id)
    primary_positions ++ RosterPosition.flex_positions
  end

  def all_positions(fantasy_league_id) do
    positions(fantasy_league_id) ++ RosterPosition.default_position()
  end

  def all_positions() do
    primary_positions = SportsLeague.Store.league_abbrevs()

    primary_positions ++
      RosterPosition.flex_positions ++
      RosterPosition.default_position
  end

  def list_all() do
    RosterPosition
    |> RosterPosition.order_by_id
    |> Repo.all
  end

  def list_all_active() do
    RosterPosition
    |> RosterPosition.all_active
    |> RosterPosition.order_by_id
    |> Repo.all
  end

  def get_by(clauses) do
    Repo.get_by(RosterPosition, clauses)
  end
end
