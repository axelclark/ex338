defmodule Ex338.SportsLeagueController do
  use Ex338.Web, :controller
  alias Ex338.{SportsLeague, Repo, User}

  def index(conn, _params) do
    sports_leagues = Repo.all(SportsLeague)
    user_league    = conn.assigns.current_user
                     |> User.my_fantasy_league
                     |> Repo.one

    render(conn, "index.html", sports_leagues: sports_leagues,
                               fantasy_league: user_league)
  end
end
