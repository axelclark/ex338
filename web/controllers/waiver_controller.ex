defmodule Ex338.WaiverController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyLeague, FantasyTeam, FantasyPlayer, Waiver, Authorization,
               NotificationEmail}

  import Canary.Plugs

  plug :load_and_authorize_resource, model: FantasyTeam, only: [:create, :new],
    preload: [:owners], persisted: true, id_name: "fantasy_team_id",
    unauthorized_handler: {Authorization, :handle_unauthorized}

  plug :load_and_authorize_resource, model: Waiver, only: [:edit, :update],
    preload: [:fantasy_team, :add_fantasy_player, :drop_fantasy_player],
    unauthorized_handler: {Authorization, :handle_unauthorized}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeague |> Repo.get(league_id)

    waivers =
      Waiver
      |> Waiver.by_league(league_id)
      |> preload([:fantasy_team, :add_fantasy_player, :drop_fantasy_player])
      |> Repo.all

    render(conn, "index.html", fantasy_league: fantasy_league,
                               waivers: waivers)
  end

  def new(conn, %{"fantasy_team_id" => team_id}) do
    fantasy_team = conn.assigns.fantasy_team
    fantasy_league = FantasyLeague |> Repo.get(fantasy_team.fantasy_league_id)

    changeset =
      fantasy_team
      |> build_assoc(:waivers)
      |> Waiver.changeset

    owned_players = team_id
                    |> FantasyTeam.owned_players
                    |> Repo.all

    avail_players = fantasy_league.id
                    |> FantasyPlayer.available_players
                    |> Repo.all

    render(conn, "new.html", changeset: changeset,
                             fantasy_team: fantasy_team,
                             fantasy_league: fantasy_league,
                             owned_players: owned_players,
                             avail_players: avail_players)
  end

  def create(conn, %{"fantasy_team_id" => team_id, "waiver" => waiver_params}) do
    fantasy_team = conn.assigns.fantasy_team

    result = fantasy_team
             |> build_assoc(:waivers)
             |> Waiver.new_changeset(waiver_params)
             |> Repo.insert

    case result do
      {:ok, waiver} ->
        waiver
        |> NotificationEmail.waiver_submitted

        conn
        |> put_flash(:info, "Waiver successfully submitted.")
        |> redirect(to: fantasy_team_path(conn, :show, team_id))
      {:error, changeset} ->
        fantasy_league = FantasyLeague
                         |> Repo.get(fantasy_team.fantasy_league_id)

        owned_players  = team_id
                         |> FantasyTeam.owned_players
                         |> Repo.all

        avail_players  = fantasy_league.id
                         |> FantasyPlayer.available_players
                         |> Repo.all

        render(conn, "new.html", changeset: changeset,
                                 fantasy_team: fantasy_team,
                                 fantasy_league: fantasy_league,
                                 owned_players: owned_players,
                                 avail_players: avail_players)
    end
  end

  def edit(conn, _) do
    waiver    = conn.assigns.waiver
    changeset = Waiver.changeset(waiver)

    render(conn, "edit.html", waiver: waiver, changeset: changeset)
  end
end
