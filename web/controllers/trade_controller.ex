defmodule Ex338.TradeController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyLeague, Trade}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeague |> Repo.get(league_id)

    trades = Trade
              |> Trade.by_league(league_id)
              |> preload(trade_line_items: [:fantasy_team,
                         fantasy_player: :sports_league])
              |> Repo.all

    render(conn, "index.html", fantasy_league: fantasy_league,
                               trades: trades)
  end
end
