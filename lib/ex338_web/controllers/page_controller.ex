defmodule Ex338Web.PageController do
  use Ex338Web, :controller

  alias Ex338.{
    FantasyLeague,
    HistoricalRecord,
    HistoricalWinning
  }

  def index(conn, _params) do
    leagues = FantasyLeague.Store.get_leagues_by_status("primary")
    season_records = HistoricalRecord.Store.get_current_season_records()
    all_time_records = HistoricalRecord.Store.get_current_all_time_records()
    winnings = HistoricalWinning.Store.get_all_winnings()

    render(conn, "index.html",
      all_time_records: all_time_records,
      fantasy_leagues: leagues,
      season_records: season_records,
      winnings: winnings
    )
  end

  def rules_2017(conn, _params) do
    render(conn, "2017_rules.html")
  end

  def rules_2018(conn, _params) do
    render(conn, "2018_rules.html")
  end

  def rules_2019(conn, _params) do
    render(conn, "2019_rules.html")
  end

  def rules_2020(conn, _params) do
    render(conn, "2020_rules.html")
  end

  def keeper_rules_2020(conn, _params) do
    render(conn, "2020_keeper_rules.html")
  end
end
