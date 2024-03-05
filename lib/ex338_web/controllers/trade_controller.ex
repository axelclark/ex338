defmodule Ex338Web.TradeController do
  use Ex338Web, :controller_html

  import Canary.Plugs

  alias Ex338.Accounts
  alias Ex338.DraftPicks
  alias Ex338.FantasyLeagues
  alias Ex338.FantasyTeams
  alias Ex338.Trades
  alias Ex338Web.Authorization
  alias Ex338Web.TradeNotifier

  plug(
    :load_and_authorize_resource,
    model: FantasyTeams.FantasyTeam,
    only: [:create, :new, :update],
    preload: [:owners, :fantasy_league],
    persisted: true,
    id_name: "fantasy_team_id",
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  plug(:scrub_params, "trade" when action in [:create, :update])

  plug(:authorize_status_update when action in [:update])

  def index(conn, %{"fantasy_league_id" => league_id}) do
    league = FantasyLeagues.get(league_id)

    render(
      conn,
      :index,
      fantasy_league: league,
      trades: Trades.all_for_league(league.id)
    )
  end

  def new(conn, %{"fantasy_team_id" => _id}) do
    team = %{fantasy_league_id: league_id} = conn.assigns.fantasy_team
    changeset = Trades.build_new_changeset()
    league_teams = FantasyTeams.list_teams_for_league(league_id)
    league_players = FantasyTeams.owned_players_for_league(league_id)
    league_future_picks = DraftPicks.list_future_picks_by_league(league_id)

    render(
      conn,
      :new,
      changeset: changeset,
      fantasy_league: team.fantasy_league,
      fantasy_team: team,
      league_future_picks: league_future_picks,
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

    case Trades.create_trade(trade_params) do
      {:ok, trade} ->
        trade = Trades.find!(trade.id)
        admin_emails = Accounts.get_admin_emails()
        recipients = Enum.uniq(Trades.Trade.get_teams_emails(trade) ++ admin_emails)

        TradeNotifier.propose(league, trade, recipients)

        conn
        |> put_flash(:info, "Trade submitted for approval.")
        |> redirect(to: ~p"/fantasy_teams/#{team}")

      {:error, %Ecto.Changeset{} = changeset} ->
        league_teams = FantasyTeams.list_teams_for_league(league.id)
        league_players = FantasyTeams.owned_players_for_league(league.id)
        league_future_picks = DraftPicks.list_future_picks_by_league(league.id)

        render(
          conn,
          "new.html",
          changeset: changeset,
          fantasy_team: team,
          league_future_picks: league_future_picks,
          league_teams: league_teams,
          league_players: league_players
        )
    end
  end

  def update(conn, %{"fantasy_team_id" => _team_id, "id" => trade_id, "trade" => trade_params}) do
    %{fantasy_league: league} = team = conn.assigns.fantasy_team

    case Trades.update_trade(trade_id, trade_params) do
      {:ok, %{trade: trade}} ->
        if(trade.status == "Canceled") do
          trade = Trades.find!(trade.id)
          admin_emails = Accounts.get_admin_emails()
          recipients = Enum.uniq(Trades.Trade.get_teams_emails(trade) ++ admin_emails)

          TradeNotifier.cancel(league, trade, recipients, team)
        end

        conn
        |> put_flash(:info, "Trade successfully processed")
        |> redirect(to: ~p"/fantasy_leagues/#{league.id}/trades")

      {:error, error} ->
        conn
        |> put_flash(:error, inspect(error))
        |> redirect(to: ~p"/fantasy_leagues/#{league.id}/trades")
    end
  end

  # Helpers

  defp authorize_status_update(
         %{params: %{"id" => trade_id, "trade" => %{"status" => "Canceled"}}} = conn,
         _opts
       ) do
    trade = Trades.find!(trade_id)

    if trade.status == "Proposed" do
      conn
    else
      conn
      |> put_flash(:error, "Can only update a proposed trade")
      |> redirect(to: "/")
      |> halt()
    end
  end

  defp authorize_status_update(conn, _opts), do: Authorization.authorize_admin(conn, [])
end
