defmodule Ex338.FantasyTeam.Store do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{FantasyTeam, RosterPosition.IRPosition, FantasyTeam.Standings,
               RosterPosition.OpenPosition, RosterPosition.RosterAdmin, Repo}

  def find_all_for_league(league_id) do
    FantasyTeam
    |> FantasyTeam.by_league(league_id)
    |> FantasyTeam.preload_assocs
    |> FantasyTeam.alphabetical
    |> Repo.all
    |> IRPosition.separate_from_active_for_teams
    |> OpenPosition.add_open_positions_to_teams
    |> Standings.add_season_ended_for_league
  end

  def find_all_for_standings(league_id) do
    FantasyTeam
    |> FantasyTeam.by_league(league_id)
    |> FantasyTeam.preload_assocs
    |> FantasyTeam.order_for_standings
    |> Repo.all
    |> Standings.rank_points_winnings_for_teams
  end

  def find(id) do
    FantasyTeam
    |> FantasyTeam.find_team(id)
    |> FantasyTeam.preload_assocs
    |> Repo.one
    |> IRPosition.separate_from_active_for_team
    |> OpenPosition.add_open_positions_to_team
    |> Standings.update_points_winnings
    |> Standings.add_season_ended
  end

  def find_for_edit(id) do
    FantasyTeam
    |> FantasyTeam.find_team(id)
    |> FantasyTeam.preload_assocs
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
