defmodule Ex338.ChampionshipController do
  use Ex338.Web, :controller
  alias Ex338.{Championship, FantasyLeague}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    render(conn, "index.html",
      championships:  Championship.get_all(Championship),
      fantasy_league: FantasyLeague.get_league(league_id)
    )
  end

  def show(conn, %{"fantasy_league_id" => league_id, "id" => id}) do
    championship =
      Championship.get_championship_by_league(Championship, id, league_id)

    render(conn, "show.html",
      championship: championship,
      fantasy_league: FantasyLeague.get_league(league_id)
    )
  end
end
