defmodule Ex338Web.FantasyTeamController do
  use Ex338Web, :controller_html

  import Canary.Plugs

  alias Ex338.FantasyLeagues
  alias Ex338.FantasyTeams
  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338Web.Authorization

  plug(
    :load_and_authorize_resource,
    model: FantasyTeam,
    only: [:edit, :update],
    preload: [:owners, :fantasy_league],
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  def index(conn, %{"fantasy_league_id" => league_id}) do
    league = FantasyLeagues.get(league_id)

    render(
      conn,
      :index,
      fantasy_league: league,
      fantasy_teams: FantasyTeams.find_all_for_league(league)
    )
  end

  def show(conn, %{"id" => id}) do
    team = FantasyTeams.find(id)

    render(
      conn,
      :show,
      fantasy_league: team.fantasy_league,
      fantasy_team: team
    )
  end

  def edit(conn, %{"id" => id}) do
    team = FantasyTeams.find_for_edit(id)

    render(
      conn,
      :edit,
      fantasy_team: team,
      changeset: FantasyTeam.owner_changeset(team),
      fantasy_league: team.fantasy_league
    )
  end

  def update(conn, %{"id" => id, "fantasy_team" => params}) do
    team = FantasyTeams.find_for_edit(id)

    case FantasyTeams.update_team(team, params) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Fantasy team updated successfully.")
        |> redirect(to: ~p"/fantasy_teams/#{team}")

      {:error, changeset} ->
        render(
          conn,
          :edit,
          fantasy_team: team,
          changeset: changeset,
          fantasy_league: team.fantasy_league
        )
    end
  end
end
