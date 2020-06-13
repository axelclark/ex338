defmodule Ex338Web.FantasyLeagueController do
  use Ex338Web, :controller

  alias Ex338.{FantasyTeams, FantasyLeagues}

  def show(conn, %{"id" => id}) do
    league = FantasyLeagues.get(id)

    render(
      conn,
      "show.html",
      fantasy_league: league,
      fantasy_teams: FantasyTeams.find_all_for_standings(league),
      standings_history: FantasyTeams.standings_history(league)
    )
  end
end
