defmodule Ex338.DraftPickControllerTest do
  use Ex338.ConnCase

  describe "index/2" do
    test "lists all draft picks in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      other_team = insert(:fantasy_team, team_name: "Another Team", 
                                         fantasy_league: other_league)
      pick = insert(:draft_pick, draft_position: 1.01, round: 1,
                                 fantasy_team: team, fantasy_league: league)
      _other_pick = insert(:draft_pick, draft_position: 1.01, round: 1,
                                        fantasy_team: other_team,
                                        fantasy_league: other_league)
      
      conn = get conn, fantasy_league_draft_pick_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Draft/
      assert String.contains?(conn.resp_body, Float.to_string(pick.draft_position))
      assert String.contains?(conn.resp_body, team.team_name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end
end
