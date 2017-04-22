defmodule Ex338.FantasyPlayerController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyLeague, FantasyPlayer}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    render(conn, "index.html",
     fantasy_league: FantasyLeague.Store.get(league_id),
     fantasy_players: FantasyPlayer.Store.all_plyrs_for_lg(league_id)
    )
  end
end
