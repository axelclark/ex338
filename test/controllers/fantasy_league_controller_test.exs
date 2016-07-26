defmodule Ex338.FantasyLeagueControllerTest do
  use Ex338.ConnCase

  describe "show/2" do
    test "shows league and lists all fantasy teams", %{conn: conn} do
      league = insert(:fantasy_league)
      team_1 = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      team_2 = insert(:fantasy_team, team_name: "Axel", fantasy_league: league)

      conn = get conn, fantasy_league_path(conn, :show, league.id)

      assert html_response(conn, 200) =~ ~r/Fantasy League/
      assert String.contains?(conn.resp_body, team_1.team_name)
      assert String.contains?(conn.resp_body, team_2.team_name)
    end
  end
end
