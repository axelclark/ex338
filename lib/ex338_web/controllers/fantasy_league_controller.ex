defmodule Ex338Web.FantasyLeagueController do
  use Ex338Web, :controller_html

  alias Ex338.FantasyLeagues
  alias Ex338.FantasyTeams

  def show(conn, %{"id" => id}) do
    league = FantasyLeagues.get(id)

    render(
      conn,
      :show,
      fantasy_league: league,
      fantasy_teams: FantasyTeams.find_all_for_standings(league),
      standings_history: FantasyTeams.standings_history(league)
    )
  end
end
