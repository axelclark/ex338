defmodule Ex338.FantasyTeam.Store do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{FantasyTeam, RosterPosition.IRPosition, FantasyTeam.Standings,
               RosterPosition.OpenPosition, RosterPosition.RosterAdmin, Repo}

  def find_all_for_league(league_id) do
    league_id
    |> FantasyTeam.all_teams
    |> FantasyTeam.alphabetical
    |> Repo.all
    |> IRPosition.separate_from_active_for_teams
    |> OpenPosition.add_open_positions_to_teams
    |> Standings.add_season_ended_for_league
  end

  def find(id) do
    FantasyTeam
    |> find_team(id)
    |> preload_assocs
    |> Repo.one
    |> IRPosition.separate_from_active_for_team
    |> OpenPosition.add_open_positions_to_team
    |> Standings.update_points_winnings
  end

  def find_for_edit(id) do
    FantasyTeam
    |> find_team(id)
    |> preload_assocs
    |> Repo.one
    |> RosterAdmin.order_by_position
  end

  def update_team(fantasy_team, fantasy_team_params) do
    fantasy_team
    |> FantasyTeam.owner_changeset(fantasy_team_params)
    |> Repo.update
  end

  defp find_team(query, id) do
    from f in query, where: f.id == ^id
  end

  defp preload_assocs(query) do
    query
    |> FantasyTeam.preload_current_positions
    |> preload([[owners: :user], :fantasy_league])
  end
end
