defmodule Ex338.InjuredReserveController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyLeague, InjuredReserve}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    render(conn, "index.html",
      fantasy_league:   FantasyLeague.Store.get(league_id),
      injured_reserves: InjuredReserve.get_all_actions(InjuredReserve, league_id)
    )
  end
end
