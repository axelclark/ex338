defmodule Ex338.FantasyTeam.Store do
  @moduledoc false

  alias Ex338.{FantasyTeam, RosterPosition.IRPosition, FantasyTeam.Standings,
               RosterPosition.OpenPosition, RosterPosition.RosterAdmin, Repo,
               RosterPosition.SeasonEnded, RosterPosition}

  def count_pending_draft_queues(team_id) do
    FantasyTeam
    |> FantasyTeam.count_pending_draft_queues(team_id)
    |> Repo.one
  end

  def find_all_for_league(league) do
    league_positions = RosterPosition.Store.positions(league.id)

    FantasyTeam
    |> FantasyTeam.by_league(league.id)
    |> FantasyTeam.preload_assocs_by_league(league)
    |> FantasyTeam.alphabetical
    |> Repo.all
    |> IRPosition.separate_from_active_for_teams
    |> OpenPosition.add_open_positions_to_teams(league_positions)
    |> SeasonEnded.add_for_league
    |> Standings.rank_points_winnings_for_teams
    |> FantasyTeam.sort_alphabetical
    |> load_slot_results
  end

  def find_all_for_standings(league) do
    FantasyTeam
    |> FantasyTeam.by_league(league.id)
    |> FantasyTeam.preload_assocs_by_league(league)
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
    %{fantasy_league: league} =
      FantasyTeam
      |> FantasyTeam.find_team(id)
      |> FantasyTeam.with_league
      |> Repo.one

    team =
      FantasyTeam
      |> FantasyTeam.find_team(id)
      |> FantasyTeam.preload_assocs_by_league(league)
      |> Repo.one

    league_positions = RosterPosition.Store.positions(team.fantasy_league_id)

    team
    |> IRPosition.separate_from_active_for_team
    |> OpenPosition.add_open_positions_to_team(league_positions)
    |> Standings.update_points_winnings
    |> SeasonEnded.add_for_team
    |> FantasyTeam.sort_queues_by_order
    |> load_slot_results
  end

  def find_for_edit(id) do
    %{fantasy_league: league} =
      FantasyTeam
      |> FantasyTeam.find_team(id)
      |> FantasyTeam.with_league
      |> Repo.one

    FantasyTeam
    |> FantasyTeam.find_team(id)
    |> FantasyTeam.preload_assocs_by_league(league)
    |> Repo.one
    |> RosterAdmin.order_by_position
    |> FantasyTeam.sort_queues_by_order
  end

  def find_owned_players(team_id) do
    FantasyTeam
    |> FantasyTeam.find_team(team_id)
    |> FantasyTeam.owned_players
    |> Repo.all
  end

  def get_team_with_active_positions(team_id) do
    FantasyTeam
    |> FantasyTeam.find_team(team_id)
    |> FantasyTeam.preload_all_active_positions
    |> Repo.one
  end

  def list_teams_for_league(league_id) do
    FantasyTeam
    |> FantasyTeam.by_league(league_id)
    |> FantasyTeam.with_league
    |> FantasyTeam.alphabetical
    |> Repo.all
  end

  def load_slot_results(
    [%FantasyTeam{fantasy_league_id: league_id} | _] = teams
  ) do
    league_id
    |> get_slot_results_for_league
    |> FantasyTeam.add_rankings_to_slot_results
    |> FantasyTeam.add_slot_results(teams)
  end

  def load_slot_results(%FantasyTeam{fantasy_league_id: league_id} = team) do
    league_id
    |> get_slot_results_for_league
    |> FantasyTeam.add_rankings_to_slot_results
    |> FantasyTeam.add_slot_results(team)
  end

  def owned_players_for_league(league_id) do
    FantasyTeam
    |> FantasyTeam.by_league(league_id)
    |> FantasyTeam.owned_players
    |> Repo.all
  end

  def update_team(fantasy_team, fantasy_team_params) do
    fantasy_team
    |> FantasyTeam.owner_changeset(fantasy_team_params)
    |> Repo.update
  end

  ## Helpers

  ## load_slot_results

  defp get_slot_results_for_league(fantasy_league_id) do
    FantasyTeam
    |> FantasyTeam.by_league(fantasy_league_id)
    |> FantasyTeam.sum_slot_points
    |> Repo.all
  end
end
