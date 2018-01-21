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
end
