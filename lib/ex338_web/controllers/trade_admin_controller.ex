defmodule Ex338Web.TradeAdminController do
  use Ex338Web, :controller

  alias Ex338.Trade

  def update(conn, %{"fantasy_league_id" => league_id, "id" => trade_id, "status" => status}) do
    case Trade.Store.process_trade(trade_id, %{"status" => status}) do
      {:ok, %{trade: _trade}} ->
        conn
        |> put_flash(:info, "Trade successfully processed")
        |> redirect(to: fantasy_league_trade_path(conn, :index, league_id))

      {:error, error} ->
        conn
        |> put_flash(:error, inspect(error))
        |> redirect(to: fantasy_league_trade_path(conn, :index, league_id))
    end
  end
end
