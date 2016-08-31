defmodule Ex338.OwnerControllerTest do
  use Ex338.ConnCase

  setup %{conn: conn} do
    user = %Ex338.User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all owners in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      user = insert_user(%{name: "Brown", email: "brown@example.com"})
      other_user = insert_user(%{name: "Axel", email: "axel@example.com"})
      insert(:owner, fantasy_team: team, user: user)
      insert(:owner, fantasy_team: other_team, user: other_user)

      conn = get conn, fantasy_league_owner_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Owners/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, user.name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end
end
