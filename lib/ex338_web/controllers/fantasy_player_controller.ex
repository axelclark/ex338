defmodule Ex338Web.FantasyPlayerController do
  use Ex338Web, :controller

  alias Ex338.{FantasyLeagues, FantasyPlayers}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeagues.get(league_id)

    render(
      conn,
      "index.html",
      fantasy_league: fantasy_league,
      fantasy_players: FantasyPlayers.all_players_for_league(fantasy_league)
    )
  end
end
