defmodule Ex338Web.ArchivedLeagueController do
  use Ex338Web, :controller_html

  alias Ex338.FantasyLeagues

  def index(conn, _params) do
    leagues = FantasyLeagues.get_leagues_by_status("archived")

    render(
      conn,
      :index,
      fantasy_leagues: leagues,
      page_title: "Past Fantasy Leagues"
    )
  end
end
