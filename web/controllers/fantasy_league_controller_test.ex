defmodule Ex338.FantasyLeagueController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyTeam, FantasyLeague}

  def show(conn, %{"id" => id}) do
    fantasy_league = FantasyLeague
      |> Repo.get!(id)
      |> Repo.preload(fantasy_teams: from(t in FantasyTeam, order_by: t.waiver_position))
    render(conn, "show.html", fantasy_league: fantasy_league)
  end
end
