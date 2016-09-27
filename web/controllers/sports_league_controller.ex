defmodule Ex338.SportsLeagueController do
  use Ex338.Web, :controller
  alias Ex338.{SportsLeague, Repo}

  def index(conn, _params) do
    sports_leagues = Repo.all(SportsLeague)

    render(conn, "index.html", sports_leagues: sports_leagues)
  end
end
