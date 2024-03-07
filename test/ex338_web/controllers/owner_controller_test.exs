defmodule Ex338Web.OwnerControllerTest do
  use Ex338Web.ConnCase

  describe "index/2" do
    test "lists all owners in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      other_team =
        insert(
          :fantasy_team,
          team_name: "Another Team",
          fantasy_league: other_league
        )

      user = insert_user(%{name: "Brown", email: "brown@example.com"})
      other_user = insert_user(%{name: "Axel", email: "axel@example.com"})
      insert(:owner, fantasy_team: team, user: user)
      insert(:owner, fantasy_team: other_team, user: other_user)

      conn = get(conn, ~p"/fantasy_leagues/#{league.id}/owners")

      assert html_response(conn, 200) =~ ~r/Owners/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, user.name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end
end
