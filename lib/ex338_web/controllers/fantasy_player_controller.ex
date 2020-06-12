defmodule Ex338Web.FantasyPlayerController do
  use Ex338Web, :controller

  alias Ex338.{FantasyLeagues, FantasyPlayer}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeagues.get(league_id)

    render(
      conn,
      "index.html",
      fantasy_league: fantasy_league,
      fantasy_players: FantasyPlayer.Store.all_players_for_league(fantasy_league)
    )
  end
end
