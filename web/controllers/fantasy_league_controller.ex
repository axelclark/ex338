defmodule Ex338.FantasyLeagueController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyTeam, FantasyLeague}

  def show(conn, %{"id" => id}) do
    render(conn, "show.html",
      fantasy_league: FantasyLeague.get_league(id),
      fantasy_teams:  FantasyTeam.get_all_teams_for_standings(id)
    )
  end
end
