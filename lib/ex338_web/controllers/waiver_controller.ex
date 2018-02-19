defmodule Ex338Web.WaiverController do
  use Ex338Web, :controller

  alias Ex338.{FantasyLeague, FantasyTeam, FantasyPlayer, Waiver, Waiver.Store}
  alias Ex338Web.{Authorization, NotificationEmail}

  import Canary.Plugs

  plug(
    :load_and_authorize_resource,
    model: FantasyTeam,
    only: [:create, :new],
    preload: [:owners, :fantasy_league],
    persisted: true,
    id_name: "fantasy_team_id",
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  plug(
    :load_and_authorize_resource,
    model: Waiver,
    only: [:edit, :update],
    preload: [
      [fantasy_team: [:owners, :fantasy_league]],
      :add_fantasy_player,
      :drop_fantasy_player
    ],
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  def index(conn, %{"fantasy_league_id" => league_id}) do
    render(
      conn,
      "index.html",
      fantasy_league: FantasyLeague.Store.get(league_id),
      waivers: Store.get_all_waivers(league_id)
    )
  end

  def new(conn, %{"fantasy_team_id" => _id}) do
    team = conn.assigns.fantasy_team

    render(
      conn,
      "new.html",
      changeset: Waiver.build_new_changeset(team),
      fantasy_team: team,
      fantasy_league: team.fantasy_league,
      owned_players: FantasyTeam.Store.find_owned_players(team.id),
      avail_players: FantasyPlayer.Store.available_players(team.fantasy_league_id)
    )
  end

  def create(conn, %{"fantasy_team_id" => _id, "waiver" => waiver_params}) do
    team = conn.assigns.fantasy_team

    case Store.create_waiver(team, waiver_params) do
      {:ok, waiver} ->
        NotificationEmail.waiver_submitted(waiver)

        conn
        |> put_flash(:info, "Waiver successfully submitted.")
        |> redirect(to: fantasy_team_path(conn, :show, team.id))

      {:error, changeset} ->
        render(
          conn,
          "new.html",
          changeset: changeset,
          fantasy_team: team,
          fantasy_league: team.fantasy_league,
          owned_players: FantasyTeam.Store.find_owned_players(team.id),
          avail_players: FantasyPlayer.Store.available_players(team.fantasy_league_id)
        )
    end
  end

  def edit(conn, %{"id" => _id}) do
    waiver = conn.assigns.waiver

    render(
      conn,
      "edit.html",
      waiver: waiver,
      owned_players: FantasyTeam.Store.find_owned_players(waiver.fantasy_team_id),
      changeset: Waiver.update_changeset(waiver),
      fantasy_league: waiver.fantasy_team.fantasy_league
    )
  end

  def update(conn, %{"id" => _id, "waiver" => params}) do
    waiver = conn.assigns.waiver

    case Store.update_waiver(waiver, params) do
      {:ok, waiver} ->
        conn
        |> put_flash(:info, "Waiver successfully updated")
        |> redirect(
          to: fantasy_league_waiver_path(conn, :index, waiver.fantasy_team.fantasy_league_id)
        )

      {:error, changeset} ->
        render(
          conn,
          "edit.html",
          changeset: changeset,
          waiver: waiver,
          owned_players: FantasyTeam.Store.find_owned_players(waiver.fantasy_team_id),
          fantasy_league: waiver.fantasy_team.fantasy_league
        )
    end
  end
end
