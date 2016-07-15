defmodule Ex338.FantasyTeamControllerTest do
  use Ex338.ConnCase

  describe "index/2" do
    test "lists all fantasy teams in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      other_team = insert(:fantasy_team, team_name: "Another Team", 
                                         fantasy_league: other_league)
      position = insert(:roster_position, position: "Any", fantasy_team: team)
      
      conn = get conn, fantasy_league_fantasy_team_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Fantasy Teams/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, position.position)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end
end
