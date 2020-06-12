defmodule Ex338Web.InjuredReserveController do
  use Ex338Web, :controller

  alias Ex338.{FantasyLeagues, InjuredReserves}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    render(
      conn,
      "index.html",
      fantasy_league: FantasyLeagues.get(league_id),
      injured_reserves: InjuredReserves.list_irs_for_league(league_id)
    )
  end
end
