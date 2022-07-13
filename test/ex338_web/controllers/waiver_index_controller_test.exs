defmodule Ex338Web.WaiverIndexControllerTest do
  use Ex338Web.ConnCase

  describe "index/2" do
    test "lists all waivers in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player = insert(:fantasy_player)
      player2 = insert(:fantasy_player)

      other_team =
        insert(
          :fantasy_team,
          team_name: "Another Team",
          fantasy_league: other_league
        )

      insert(:waiver, fantasy_team: team, add_fantasy_player: player, status: "successful")
      insert(:waiver, fantasy_team: other_team, add_fantasy_player: player, status: "successful")
      insert(:waiver, fantasy_team: team, add_fantasy_player: player2, status: "pending")

      conn = get(conn, fantasy_league_waiver_path(conn, :index, league.id))

      assert html_response(conn, 200) =~ ~r/Waivers/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player.player_name)
      assert String.contains?(conn.resp_body, player2.player_name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end
end
