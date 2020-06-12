defmodule Ex338Web.FantasyLeagueController do
  use Ex338Web, :controller

  alias Ex338.{FantasyTeam, FantasyLeagues}

  def show(conn, %{"id" => id}) do
    league = FantasyLeagues.get(id)

    render(
      conn,
      "show.html",
      fantasy_league: league,
      fantasy_teams: FantasyTeam.Store.find_all_for_standings(league),
      standings_history: FantasyTeam.Store.standings_history(league)
    )
  end
end
