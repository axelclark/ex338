defmodule Ex338Web.TradeController do
  use Ex338Web, :controller

  alias Ex338.{FantasyLeague, Trade, FantasyTeam, User}
  alias Ex338Web.{Authorization, TradeEmail, Mailer}

  import Canary.Plugs

  plug(
    :load_and_authorize_resource,
    model: FantasyTeam,
    only: [:create, :new, :update],
    preload: [:owners, :fantasy_league],
    persisted: true,
    id_name: "fantasy_team_id",
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  plug(:scrub_params, "trade" when action in [:create, :update])

  plug(:authorize_status_update when action in [:update])

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
      fantasy_league: team.fantasy_league,
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
        trade = Trade.Store.find!(trade.id)
        admin_emails = User.Store.get_admin_emails()
        recipients = (Trade.get_teams_emails(trade) ++ admin_emails) |> Enum.uniq()

        conn
        |> TradeEmail.propose(league, trade, recipients)
        |> Mailer.deliver()
        |> Mailer.handle_delivery()

        conn
        |> put_flash(:info, "Trade submitted for approval.")
        |> redirect(to: Routes.fantasy_team_path(conn, :show, team))

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

  def update(conn, %{
        "fantasy_team_id" => _team_id,
        "id" => trade_id,
        "trade" => trade_params
      }) do
    %{fantasy_league: league} = team = conn.assigns.fantasy_team

    case Trade.Store.update_trade(trade_id, trade_params) do
      {:ok, %{trade: trade}} ->
        if(trade.status == "Canceled") do
          trade = Trade.Store.find!(trade.id)
          admin_emails = User.Store.get_admin_emails()
          recipients = (Trade.get_teams_emails(trade) ++ admin_emails) |> Enum.uniq()

          conn
          |> TradeEmail.cancel(league, trade, recipients, team)
          |> Mailer.deliver()
          |> Mailer.handle_delivery()
        end

        conn
        |> put_flash(:info, "Trade successfully processed")
        |> redirect(to: Routes.fantasy_league_trade_path(conn, :index, league.id))

      {:error, error} ->
        conn
        |> put_flash(:error, inspect(error))
        |> redirect(to: Routes.fantasy_league_trade_path(conn, :index, league.id))
    end
  end

  # Helpers

  defp authorize_status_update(
         %{params: %{"id" => trade_id, "trade" => %{"status" => "Canceled"}}} = conn,
         _opts
       ) do
    trade = Trade.Store.find!(trade_id)

    case trade.status == "Proposed" do
      true ->
        conn

      false ->
        conn
        |> put_flash(:error, "Can only update a proposed trade")
        |> redirect(to: "/")
        |> halt
    end
  end

  defp authorize_status_update(conn, _opts), do: Authorization.authorize_admin(conn, [])
end
