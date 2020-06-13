defmodule Ex338Web.FantasyTeamController do
  use Ex338Web, :controller

  alias Ex338.{FantasyTeams, FantasyTeams.FantasyTeam, FantasyLeagues}
  alias Ex338Web.{Authorization}

  import Canary.Plugs

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
      "index.html",
      fantasy_league: league,
      fantasy_teams: FantasyTeams.find_all_for_league(league)
    )
  end

  def show(conn, %{"id" => id}) do
    team = FantasyTeams.find(id)

    render(
      conn,
      "show.html",
      fantasy_league: team.fantasy_league,
      fantasy_team: team
    )
  end

  def edit(conn, %{"id" => id}) do
    team = FantasyTeams.find_for_edit(id)

    render(
      conn,
      "edit.html",
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
        |> redirect(to: Routes.fantasy_team_path(conn, :show, team))

      {:error, changeset} ->
        render(
          conn,
          "edit.html",
          fantasy_team: team,
          changeset: changeset
        )
    end
  end
end
