defmodule Ex338Web.ChampionshipController do
  use Ex338Web, :controller
  alias Ex338.{Championships, FantasyLeagues}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    render(
      conn,
      "index.html",
      championships: Championships.all_for_league(league_id),
      fantasy_league: FantasyLeagues.get(league_id)
    )
  end

  def show(conn, %{"fantasy_league_id" => league_id, "id" => id}) do
    render(
      conn,
      "show.html",
      championship: Championships.get_championship_by_league(id, league_id),
      fantasy_league: FantasyLeagues.get(league_id)
    )
  end
end
