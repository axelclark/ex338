defmodule Ex338.FantasyTeamController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyTeam, FantasyLeague, Authorization, RosterAdmin}

  import Canary.Plugs

  plug :load_and_authorize_resource, model: FantasyTeam, only: [:edit, :update],
    preload: [:owners],
    unauthorized_handler: {Authorization, :handle_unauthorized}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeague |> Repo.get(league_id)

    fantasy_teams = FantasyTeam
                    |> FantasyLeague.by_league(league_id)
                    |> preload(roster_positions: [fantasy_player: :sports_league])
                    |> FantasyTeam.alphabetical
                    |> Repo.all
                    |> RosterAdmin.add_open_positions_to_teams

    render(conn, "index.html", fantasy_league: fantasy_league,
                               fantasy_teams: fantasy_teams)
  end

  def show(conn, %{"id" => id}) do
    team = FantasyTeam
           |> preload([[roster_positions: [fantasy_player: :sports_league]],
                       [owners: :user], :fantasy_league])
           |> Repo.get!(id)
           |> RosterAdmin.add_open_positions_to_team


    league = team.fantasy_league

    render(conn, "show.html", fantasy_league: league, fantasy_team: team)
  end

  def edit(conn, %{"id" => _}) do
    fantasy_team = conn.assigns.fantasy_team
    changeset = FantasyTeam.changeset(fantasy_team)
    league = FantasyLeague |> Repo.get!(fantasy_team.fantasy_league_id)

    render(conn, "edit.html", fantasy_team: fantasy_team, changeset: changeset,
                              fantasy_league: league)
  end

  def update(conn, %{"id" => _, "fantasy_team" => fantasy_team_params}) do
    fantasy_team = conn.assigns.fantasy_team
    changeset = FantasyTeam.changeset(fantasy_team, fantasy_team_params)

    case Repo.update(changeset) do
      {:ok, fantasy_team} ->
        conn
        |> put_flash(:info, "Fantasy team updated successfully.")
        |> redirect(to: fantasy_team_path(conn, :show, fantasy_team))
      {:error, changeset} ->
        render(conn, "edit.html", fantasy_team: fantasy_team, changeset: changeset)
    end
  end
end
