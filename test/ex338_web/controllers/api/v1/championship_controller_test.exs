defmodule Ex338Web.Api.V1.ChampionshipControllerTest do
  use Ex338Web.ConnCase

  describe "GET /api/v1/fantasy_leagues/:fantasy_league_id/championships" do
    test "returns championships for a league", %{conn: conn} do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      insert(:championship,
        sports_league: sport,
        category: "overall",
        year: league.year
      )

      conn = get(conn, ~p"/api/v1/fantasy_leagues/#{league.id}/championships")

      assert %{"championships" => championships} = json_response(conn, 200)
      assert length(championships) >= 1
      [champ] = championships
      assert champ["title"]
      assert champ["category"]
      assert champ["sports_league"]
    end
  end

  describe "GET /api/v1/fantasy_leagues/:fantasy_league_id/championships/:id" do
    test "returns championship with results", %{conn: conn} do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)

      championship =
        insert(:championship,
          sports_league: sport,
          category: "overall",
          year: league.year
        )

      conn =
        get(
          conn,
          ~p"/api/v1/fantasy_leagues/#{league.id}/championships/#{championship.id}"
        )

      assert %{"championship" => data} = json_response(conn, 200)
      assert data["id"] == championship.id
      assert data["title"]
      assert is_list(data["championship_results"])
      assert is_list(data["championship_slots"])
    end

    test "returns 404 for non-existent championship", %{conn: conn} do
      league = insert(:fantasy_league)

      conn = get(conn, ~p"/api/v1/fantasy_leagues/#{league.id}/championships/0")

      assert json_response(conn, 404)["error"]
    end
  end
end
