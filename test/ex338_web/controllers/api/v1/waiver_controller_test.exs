defmodule Ex338Web.Api.V1.WaiverControllerTest do
  use Ex338Web.ConnCase

  describe "GET /api/v1/fantasy_leagues/:fantasy_league_id/waivers" do
    test "returns waivers for a league", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, waiver_position: 1)
      add_player = insert(:fantasy_player)
      drop_player = insert(:fantasy_player)

      insert(:waiver,
        fantasy_team: team,
        add_fantasy_player: add_player,
        drop_fantasy_player: drop_player,
        status: "successful"
      )

      conn = get(conn, ~p"/api/v1/fantasy_leagues/#{league.id}/waivers")

      assert %{"waivers" => waivers} = json_response(conn, 200)
      assert length(waivers) == 1
      [waiver] = waivers
      assert waiver["status"] == "successful"
      assert waiver["fantasy_team"]["team_name"]
      assert waiver["add_fantasy_player"]["player_name"]
      assert waiver["drop_fantasy_player"]["player_name"]
    end
  end
end
