defmodule Ex338Web.FantasyTeamController do
  use Ex338Web, :controller

  alias Ex338.FantasyLeagues
  alias Ex338.FantasyTeams

  def index(conn, %{"fantasy_league_id" => league_id}) do
    league = FantasyLeagues.get(league_id)

    render(
      conn,
      :index,
      fantasy_league: league,
      fantasy_teams: FantasyTeams.find_all_for_league(league)
    )
  end
end
