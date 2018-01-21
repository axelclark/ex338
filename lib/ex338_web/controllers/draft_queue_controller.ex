defmodule Ex338Web.DraftQueueController do
  use Ex338Web, :controller

  alias Ex338.{FantasyTeam, FantasyPlayer, DraftQueue}
  alias Ex338Web.{Authorization}

  import Canary.Plugs

  plug :load_and_authorize_resource, model: FantasyTeam, only: [:create, :new],
    preload: [:owners, :fantasy_league], persisted: true,
    id_name: "fantasy_team_id",
    unauthorized_handler: {Authorization, :handle_unauthorized}

  def new(conn, %{"fantasy_team_id" => _id}) do
    team = conn.assigns.fantasy_team

    players =
      FantasyPlayer.Store.available_players(team.fantasy_league_id)

    changeset = DraftQueue.changeset(%DraftQueue{})

    render(
      conn,
      "new.html",
      fantasy_team: team,
      available_players: players,
      changeset: changeset
    )
  end

  def create(conn, %{"fantasy_team_id" => team_id, "draft_queue" => params}) do
    updated_params = Map.put(params, "fantasy_team_id", team_id)
    case DraftQueue.Store.create_draft_queue(updated_params) do
      {:ok, _draft_queue} ->
        conn
        |> put_flash(:info, "Draft queue created successfully.")
        |> redirect(to: fantasy_team_path(conn, :show, team_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        team = conn.assigns.fantasy_team
        players =
          FantasyPlayer.Store.available_players(team.fantasy_league_id)

        render(
          conn,
          "new.html",
          fantasy_team: team,
          available_players: players,
          changeset: changeset
        )
    end
  end
end
