defmodule Ex338.FantasyTeamController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyTeam, FantasyLeague, Authorization}

  import Canary.Plugs

  plug :load_and_authorize_resource, model: FantasyTeam, only: [:edit, :update],
    preload: [:owners, :fantasy_league],
    unauthorized_handler: {Authorization, :handle_unauthorized}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    render(conn, "index.html",
      fantasy_league: FantasyLeague.get_league(league_id),
      fantasy_teams:  FantasyTeam.get_all_teams_with_open_positions(league_id)
    )
  end

  def show(conn, %{"id" => id}) do
    team = FantasyTeam.Store.find(id)

    render(conn, "show.html",
      fantasy_league: team.fantasy_league,
      fantasy_team:   team
    )
  end

  def edit(conn, %{"id" => id}) do
    team = FantasyTeam.Store.find_for_update(id)

    render(conn, "edit.html",
      fantasy_team:   team,
      changeset:      FantasyTeam.owner_changeset(team),
      fantasy_league: team.fantasy_league
    )
  end

  def update(conn, %{"id" => id, "fantasy_team" => params}) do
    team = FantasyTeam.Store.find_for_update(id)

    case FantasyTeam.update_team(team, params) do
      {:ok, team} ->
        conn
        |> put_flash(:info, "Fantasy team updated successfully.")
        |> redirect(to: fantasy_team_path(conn, :show, team))

      {:error, changeset} ->
        render(conn, "edit.html",
          fantasy_team: team,
          changeset:    changeset
        )
    end
  end
end
