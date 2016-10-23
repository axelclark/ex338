defmodule Ex338.FantasyTeamController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyTeam, FantasyLeague, Authorization}

  import Canary.Plugs

  plug :load_and_authorize_resource, model: FantasyTeam, only: [:edit, :update],
    preload: [:owners, :fantasy_league],
    unauthorized_handler: {Authorization, :handle_unauthorized}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeague |> Repo.get(league_id)
    fantasy_teams  = FantasyTeam.get_all_teams(league_id)

    render(conn, "index.html",
      fantasy_league: fantasy_league,
      fantasy_teams: fantasy_teams
    )
  end

  def show(conn, %{"id" => id}) do
    team = FantasyTeam.get_team(id)

    render(conn, "show.html",
      fantasy_league: team.fantasy_league,
      fantasy_team: team
    )
  end

  def edit(conn, %{"id" => id}) do
    fantasy_team = FantasyTeam.get_team_to_update(id)

    render(conn, "edit.html",
      fantasy_team: fantasy_team,
      changeset: FantasyTeam.owner_changeset(fantasy_team),
      fantasy_league: conn.assigns.fantasy_team.fantasy_league
    )
  end

  def update(conn, %{"id" => id, "fantasy_team" => params}) do
    fantasy_team = FantasyTeam.get_team_to_update(id)

    case FantasyTeam.update_team(fantasy_team, params) do
      {:ok, fantasy_team} ->
        conn
        |> put_flash(:info, "Fantasy team updated successfully.")
        |> redirect(to: fantasy_team_path(conn, :show, fantasy_team))
      {:error, changeset} ->
        render(conn, "edit.html",
          fantasy_team: fantasy_team,
          changeset: changeset
        )
    end
  end
end
