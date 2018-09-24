defmodule Ex338Web.DraftPickControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.{User, DraftPick, DraftQueue}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all draft picks in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      other_team =
        insert(
          :fantasy_team,
          team_name: "Another Team",
          fantasy_league: other_league
        )

      pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team, fantasy_league: league)

      _other_pick =
        insert(
          :draft_pick,
          draft_position: 1.01,
          fantasy_team: other_team,
          fantasy_league: other_league
        )

      conn = get(conn, fantasy_league_draft_pick_path(conn, :index, league.id))

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
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team, fantasy_league: league)
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      insert(:championship, sports_league: sport)

      conn = get(conn, draft_pick_path(conn, :edit, pick.id))

      assert html_response(conn, 200) =~ ~r/Submit Draft Pick/
      assert String.contains?(conn.resp_body, player.player_name)
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:fantasy_player)
      pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team, fantasy_league: league)

      conn = get(conn, draft_pick_path(conn, :edit, pick.id))

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "update/2" do
    test "updates a draft pick and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player = insert(:fantasy_player)
      drafted_queue = insert(:draft_queue, fantasy_team: team, fantasy_player: player)
      pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team, fantasy_league: league)

      team2 = insert(:fantasy_team, fantasy_league: league)
      unavailable_queue = insert(:draft_queue, fantasy_team: team2, fantasy_player: player)

      conn =
        patch(
          conn,
          draft_pick_path(conn, :update, pick.id, draft_pick: %{fantasy_player_id: player.id})
        )

      assert redirected_to(conn) == fantasy_league_draft_pick_path(conn, :index, league.id)
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == player.id
      assert Repo.get!(DraftQueue, unavailable_queue.id).status == :unavailable
      assert Repo.get!(DraftQueue, drafted_queue.id).status == :drafted
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team, fantasy_league: league)

      sport = insert(:sports_league)
      insert(:fantasy_player, sports_league: sport)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      insert(:championship, sports_league: sport)

      conn =
        patch(
          conn,
          draft_pick_path(conn, :update, pick.id, draft_pick: %{fantasy_player_id: nil})
        )

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:fantasy_player)
      pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team, fantasy_league: league)

      conn =
        patch(
          conn,
          draft_pick_path(conn, :update, pick.id, draft_pick: %{fantasy_player_id: nil})
        )

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
