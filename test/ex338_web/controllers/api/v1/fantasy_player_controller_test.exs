defmodule Ex338Web.Api.V1.FantasyPlayerControllerTest do
  use Ex338Web.ConnCase

  describe "GET /api/v1/fantasy_leagues/:fantasy_league_id/fantasy_players" do
    test "returns players for a league", %{conn: conn} do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:fantasy_player, sports_league: sport)

      conn = get(conn, ~p"/api/v1/fantasy_leagues/#{league.id}/fantasy_players")

      assert %{"fantasy_players" => players} = json_response(conn, 200)
      assert length(players) >= 1
      [player] = players
      assert player["player_name"]
      assert player["sports_league"]
    end

    test "returns 404 for non-existent league", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/fantasy_leagues/0/fantasy_players")

      assert json_response(conn, 404)["error"]
    end
  end
end
