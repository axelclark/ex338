defmodule Ex338Web.Api.V1.FantasyPlayerController do
  use Ex338Web, :controller

  alias Ex338.FantasyLeagues
  alias Ex338.FantasyPlayers

  action_fallback Ex338Web.Api.V1.FallbackController

  def index(conn, %{"fantasy_league_id" => league_id}) do
    league = FantasyLeagues.get(league_id)

    with %{} <- league do
      players_by_sport = FantasyPlayers.all_players_for_league(league)
      render(conn, :index, players_by_sport: players_by_sport)
    end
  end
end
