defmodule Ex338.FantasyLeagueController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyTeam, FantasyLeague}

  def show(conn, %{"id" => id}) do
    render(conn, "show.html",
      fantasy_league: FantasyLeague.Store.get(id),
      fantasy_teams:  FantasyTeam.Store.find_all_for_standings(id)
    )
  end
end
