defmodule Ex338.RosterPositions do
  @moduledoc false

  alias Ex338.{
    FantasyLeagues.FantasyLeague,
    RosterPositions.RosterPosition,
    Repo,
    FantasyPlayers
  }

  def get_by(clauses) do
    Repo.get_by(RosterPosition, clauses)
  end

  def list_all() do
    RosterPosition
    |> RosterPosition.order_by_id()
    |> Repo.all()
  end

  def list_all_active() do
    RosterPosition
    |> RosterPosition.all_active()
    |> RosterPosition.order_by_id()
    |> Repo.all()
  end

  def positions(%FantasyLeague{only_flex?: true, max_flex_spots: max_flex_spots}) do
    RosterPosition.flex_positions(max_flex_spots)
  end

  def positions(%FantasyLeague{id: fantasy_league_id, max_flex_spots: max_flex_spots}) do
    primary_positions = FantasyPlayers.list_sports_abbrevs(fantasy_league_id)
    primary_positions ++ RosterPosition.flex_positions(max_flex_spots)
  end

  def positions_for_draft(fantasy_league_id, championship_id) do
    RosterPosition
    |> RosterPosition.all_active()
    |> RosterPosition.all_draft_picks()
    |> RosterPosition.from_league(fantasy_league_id)
    |> RosterPosition.sport_from_champ(championship_id)
    |> RosterPosition.preload_assocs()
    |> Repo.all()
  end
end
