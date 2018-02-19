defmodule Ex338Web.TradeController do
  use Ex338Web, :controller

  alias Ex338.{FantasyLeague, Trade, FantasyTeam, User}
  alias Ex338Web.{Authorization, TradeEmail, Mailer}

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

  plug(:scrub_params, "trade" when action in [:create, :update])

  def index(conn, %{"fantasy_league_id" => league_id}) do
    league = FantasyLeague.Store.get(league_id)

    user_with_team = User.Store.preload_team_by_league(conn.assigns.current_user, league_id)

    conn = assign(conn, :current_user, user_with_team)

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
      league_players: league_players
    )
  end

  def create(conn, %{"fantasy_team_id" => _id, "trade" => trade_params}) do
    team = %{fantasy_league: league} = conn.assigns.fantasy_team

    trade_params =
      trade_params
      |> Map.put("submitted_by_user_id", conn.assigns.current_user.id)
      |> Map.put("submitted_by_team_id", team.id)

    case Trade.Store.create_trade(trade_params) do
      {:ok, trade} ->
        recipients = User.Store.get_league_and_admin_emails(league.id)
        trade = Trade.Store.load_line_items(trade)

        conn
        |> TradeEmail.new(league, trade, recipients)
        |> Mailer.deliver()
        |> Mailer.handle_delivery()

        conn
        |> put_flash(:info, "Trade submitted for approval.")
        |> redirect(to: fantasy_team_path(conn, :show, team))

      {:error, %Ecto.Changeset{} = changeset} ->
        league_teams = FantasyTeam.Store.list_teams_for_league(league.id)
        league_players = FantasyTeam.Store.owned_players_for_league(league.id)

        render(
          conn,
          "new.html",
          changeset: changeset,
          fantasy_team: team,
          league_teams: league_teams,
          league_players: league_players
        )
    end
  end
end
