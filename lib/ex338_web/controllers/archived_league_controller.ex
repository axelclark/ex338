defmodule Ex338Web.ArchivedLeagueController do
  use Ex338Web, :controller

  alias Ex338.{FantasyLeague}

  def index(conn, _params) do
    leagues = FantasyLeague.Store.get_leagues_by_status("archived")

    render(
      conn,
      "index.html",
      fantasy_leagues: leagues
    )
  end
end
