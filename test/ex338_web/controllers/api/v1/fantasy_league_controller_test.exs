defmodule Ex338Web.Api.V1.FantasyLeagueControllerTest do
  use Ex338Web.ConnCase

  describe "GET /api/v1/fantasy_leagues" do
    test "returns list of primary leagues", %{conn: conn} do
      insert(:fantasy_league, navbar_display: "primary")
      insert(:fantasy_league, navbar_display: "archived")

      conn = get(conn, ~p"/api/v1/fantasy_leagues")

      assert %{"fantasy_leagues" => leagues} = json_response(conn, 200)
      assert length(leagues) == 1
      [league] = leagues
      assert league["fantasy_league_name"]
      assert league["year"]
      assert league["division"]
      assert league["id"]
    end
  end

  describe "GET /api/v1/fantasy_leagues/:id" do
    test "returns league with standings", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, waiver_position: 1)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position,
        fantasy_team: team,
        fantasy_player: player,
        status: "active"
      )

      conn = get(conn, ~p"/api/v1/fantasy_leagues/#{league.id}")

      assert %{"fantasy_league" => data} = json_response(conn, 200)
      assert data["id"] == league.id
      assert data["fantasy_league_name"] == league.fantasy_league_name
      assert is_list(data["standings"])
    end

    test "returns 404 for non-existent league", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/fantasy_leagues/0")

      assert json_response(conn, 404)["error"]
    end
  end
end
