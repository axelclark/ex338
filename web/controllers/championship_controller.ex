defmodule Ex338.ChampionshipController do
  use Ex338.Web, :controller
  alias Ex338.{Championship, FantasyLeague}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    render(conn, "index.html",
      championships:  Championship.Store.all_for_league(league_id),
      fantasy_league: FantasyLeague.Store.get(league_id)
    )
  end

  def show(conn, %{"fantasy_league_id" => league_id, "id" => id}) do
    render(conn, "show.html",
      championship: Championship.Store.get_championship_by_league(id, league_id),
      fantasy_league: FantasyLeague.Store.get(league_id)
    )
  end
end
