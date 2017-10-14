defmodule Ex338Web.FantasyPlayerController do
  use Ex338Web, :controller

  alias Ex338.{FantasyLeague, FantasyPlayer}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeague.Store.get(league_id)

    render(conn, "index.html",
     fantasy_league: fantasy_league,
     fantasy_players: FantasyPlayer.Store.all_plyrs_for_lg(fantasy_league)
    )
  end
end
