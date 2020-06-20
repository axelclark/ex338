defmodule Ex338Web.PageController do
  use Ex338Web, :controller

  alias Ex338.{FantasyLeagues}

  def index(conn, _params) do
    leagues = FantasyLeagues.get_leagues_by_status("primary")
    season_records = FantasyLeagues.list_current_season_records()
    all_time_records = FantasyLeagues.list_current_all_time_records()
    winnings = FantasyLeagues.list_all_winnings()

    render(conn, "index.html",
      all_time_records: all_time_records,
      fantasy_leagues: leagues,
      page_title: "338 Challenge",
      season_records: season_records,
      winnings: winnings
    )
  end

  def rules(conn, %{"fantasy_league_id" => id}) do
    fantasy_league = FantasyLeagues.get(id)
    render(conn, "rules.html", fantasy_league: fantasy_league)
  end
end
