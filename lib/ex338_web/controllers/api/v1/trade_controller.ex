defmodule Ex338Web.Api.V1.TradeController do
  use Ex338Web, :controller

  alias Ex338.Trades

  def index(conn, %{"fantasy_league_id" => league_id}) do
    trades = Trades.all_for_league(league_id)
    render(conn, :index, trades: trades)
  end
end
