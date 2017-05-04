defmodule Ex338.TradeController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyLeague, Trade}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    league = FantasyLeague.Store.get(league_id)

    render(conn, "index.html",
     fantasy_league: league,
     trades: Trade.Store.all_for_league(league.id)
    )
  end
end
