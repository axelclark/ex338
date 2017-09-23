defmodule Ex338.FantasyTeam.Store do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{FantasyTeam, RosterPosition.IRPosition, FantasyTeam.Standings,
               RosterPosition.OpenPosition, RosterPosition.RosterAdmin, Repo,
               RosterPosition}

  def find_all_for_league(league_id) do
    league_positions = RosterPosition.Store.positions(league_id)

    FantasyTeam
    |> FantasyTeam.by_league(league_id)
    |> FantasyTeam.preload_all_assocs
    |> FantasyTeam.alphabetical
    |> Repo.all
    |> IRPosition.separate_from_active_for_teams
    |> OpenPosition.add_open_positions_to_teams(league_positions)
    |> Standings.add_season_ended_for_league
  end

  def find_all_for_standings(league_id) do
    FantasyTeam
    |> FantasyTeam.by_league(league_id)
    |> FantasyTeam.preload_all_assocs
    |> FantasyTeam.order_by_waiver_position
    |> Repo.all
    |> Standings.rank_points_winnings_for_teams
  end

  def find_all_for_league_sport(league_id, sports_league_id) do
    FantasyTeam
    |> FantasyTeam.by_league(league_id)
    |> FantasyTeam.preload_active_positions_for_sport(sports_league_id)
    |> Repo.all
  end

  def find(id) do
    team =
      FantasyTeam
      |> FantasyTeam.find_team(id)
      |> FantasyTeam.preload_all_assocs
      |> Repo.one

    league_positions = RosterPosition.Store.positions(team.fantasy_league_id)

    team
    |> IRPosition.separate_from_active_for_team
    |> OpenPosition.add_open_positions_to_team(league_positions)
    |> Standings.update_points_winnings
    |> Standings.add_season_ended
  end

  def find_for_edit(id) do
    FantasyTeam
    |> FantasyTeam.find_team(id)
    |> FantasyTeam.preload_all_assocs
    |> Repo.one
    |> RosterAdmin.order_by_position
  end

  def find_owned_players(team_id) do
    team_id
    |> FantasyTeam.owned_players
    |> Repo.all
  end

  def update_team(fantasy_team, fantasy_team_params) do
    fantasy_team
    |> FantasyTeam.owner_changeset(fantasy_team_params)
    |> Repo.update
  end
end
