defmodule Ex338Web.TradeController do
  use Ex338Web, :controller

  alias Ex338.{FantasyLeague, Trade, FantasyTeam}
  alias Ex338Web.{Authorization}

  import Canary.Plugs

  plug :load_and_authorize_resource, model: FantasyTeam, only: [:create, :new],
    preload: [:owners, :fantasy_league], persisted: true,
    id_name: "fantasy_team_id",
    unauthorized_handler: {Authorization, :handle_unauthorized}

  plug :scrub_params, "trade" when action in [:create, :update]

  def index(conn, %{"fantasy_league_id" => league_id}) do
    league = FantasyLeague.Store.get(league_id)

    render(
      conn,
      "index.html",
      fantasy_league: league,
      trades: Trade.Store.all_for_league(league.id)
    )
  end

  def new(conn, %{"fantasy_team_id" => _id}) do
    team = %{fantasy_league_id: league_id} = conn.assigns.fantasy_team
    changeset = Trade.Store.build_new_changeset()
    league_teams = FantasyTeam.Store.list_teams_for_league(league_id)
    league_players = FantasyTeam.Store.owned_players_for_league(league_id)

    render(
      conn,
      "new.html",
      changeset: changeset,
      fantasy_team: team,
      league_teams: league_teams,
      league_players: league_players,
    )
  end

  def create(conn, %{"fantasy_team_id" => _team_id, "trade" => trade_params}) do
    team = %{fantasy_league_id: league_id} = conn.assigns.fantasy_team
    case Trade.Store.create_trade(trade_params) do
      {:ok, _trade} ->
        conn
        |> put_flash(:info, "Fantasy team updated successfully.")
        |> redirect(to: fantasy_team_path(conn, :show, team))
      {:error, %Ecto.Changeset{} = changeset} ->
        league_teams = FantasyTeam.Store.list_teams_for_league(league_id)
        league_players = FantasyTeam.Store.owned_players_for_league(league_id)

        render(
          conn,
          "new.html",
          changeset: changeset,
          fantasy_team: team,
          league_teams: league_teams,
          league_players: league_players,
        )
    end
  end
end
