defmodule Ex338Web.Api.V1.InjuredReserveControllerTest do
  use Ex338Web.ConnCase

  describe "GET /api/v1/fantasy_leagues/:fantasy_league_id/injured_reserves" do
    test "returns injured reserves for a league", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, waiver_position: 1)
      injured_player = insert(:fantasy_player)
      replacement_player = insert(:fantasy_player)

      insert(:injured_reserve,
        fantasy_team: team,
        injured_player: injured_player,
        replacement_player: replacement_player,
        status: "approved"
      )

      conn = get(conn, ~p"/api/v1/fantasy_leagues/#{league.id}/injured_reserves")

      assert %{"injured_reserves" => irs} = json_response(conn, 200)
      assert length(irs) == 1
      [ir] = irs
      assert ir["status"] == "approved"
      assert ir["fantasy_team"]["team_name"]
      assert ir["injured_player"]["player_name"]
      assert ir["replacement_player"]["player_name"]
    end
  end
end
