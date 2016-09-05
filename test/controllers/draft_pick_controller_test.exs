defmodule Ex338.DraftPickControllerTest do
  use Ex338.ConnCase

  setup %{conn: conn} do
    user = %Ex338.User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all draft picks in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team,
                                 fantasy_league: league)
      _other_pick = insert(:draft_pick, draft_position: 1.01,
                                        fantasy_team: other_team,
                                        fantasy_league: other_league)

      conn = get conn, fantasy_league_draft_pick_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Draft/
      assert String.contains?(conn.resp_body, Float.to_string(pick.draft_position))
      assert String.contains?(conn.resp_body, team.team_name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end

  describe "edit/2" do
    test "renders a form to submit a draft pick", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:fantasy_player)
      pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team,
                                 fantasy_league: league)

      conn = get conn, draft_pick_path(conn, :edit, pick.id)

      assert html_response(conn, 200) =~ ~r/Submit Draft Pick/
    end
  end

  describe "update/2" do
    test "updates a draft pick and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player = insert(:fantasy_player)
      pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team,
                                 fantasy_league: league)

      conn = patch conn, draft_pick_path(conn, :update, pick.id,
               draft_pick: %{fantasy_player_id: player.id})

      assert redirected_to(conn) == fantasy_league_draft_pick_path(conn, :index, league.id)
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player = insert(:fantasy_player)
      pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team,
                                 fantasy_league: league)

      conn = patch conn, draft_pick_path(conn, :update, pick.id,
               draft_pick: %{fantasy_player_id: nil})

      assert html_response(conn, 200) =~ "Please check the errors below."
    end
  end
end
