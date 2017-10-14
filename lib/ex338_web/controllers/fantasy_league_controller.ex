defmodule Ex338Web.FantasyLeagueController do
  use Ex338Web, :controller

  alias Ex338.{FantasyTeam, FantasyLeague}

  def show(conn, %{"id" => id}) do
    league = FantasyLeague.Store.get(id)
    render(conn, "show.html",
      fantasy_league: league,
      fantasy_teams:  FantasyTeam.Store.find_all_for_standings(league)
    )
  end
end
