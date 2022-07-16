defmodule Ex338Web.FantasyTeamUpdateControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.{
    Accounts.User,
    FantasyTeams.FantasyTeam,
    DraftQueues.DraftQueue,
    RosterPositions.RosterPosition
  }

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "edit/2" do
    test "renders a form to update a team", %{conn: conn} do
      team = insert(:fantasy_team)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      pos = insert(:roster_position, fantasy_team: team)
      queue = insert(:draft_queue, fantasy_team: team)

      conn = get(conn, fantasy_team_path(conn, :edit, team.id))

      assert html_response(conn, 200) =~ ~r/Update Team Info/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, pos.fantasy_player.player_name)
      assert String.contains?(conn.resp_body, queue.fantasy_player.player_name)
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      team = insert(:fantasy_team, team_name: "Brown")

      conn = get(conn, fantasy_team_path(conn, :edit, team.id))

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "update/2" do
    test "updates a fantasy team name and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      conn =
        patch(conn, fantasy_team_path(conn, :update, team, fantasy_team: %{team_name: "Cubs"}))

      assert redirected_to(conn) == fantasy_team_path(conn, :show, team.id)
      assert Repo.get!(FantasyTeam, team.id).team_name == "Cubs"
    end

    test "updates a fantasy team's draft queues and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      queue1 = insert(:draft_queue, fantasy_team: team, order: 1)
      queue2 = insert(:draft_queue, fantasy_team: team, order: 2)
      canx_queue = insert(:draft_queue, fantasy_team: team, order: 3)

      attrs = %{
        "draft_queues" => %{
          "0" => %{"id" => queue1.id, "order" => 2, "status" => "pending"},
          "1" => %{"id" => queue2.id, "order" => 1, "status" => "pending"},
          "2" => %{"id" => canx_queue.id, "order" => 3, "status" => "cancelled"}
        }
      }

      conn = patch(conn, fantasy_team_path(conn, :update, team, fantasy_team: attrs))

      [q1, q2, canx_q] = Repo.all(DraftQueue)

      assert redirected_to(conn) == fantasy_team_path(conn, :show, team.id)
      assert q1.order == 2
      assert q2.order == 1
      assert canx_q.status == :cancelled
    end

    test "updates a fantasy team's roster and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      pos1 = insert(:roster_position, fantasy_team: team)
      pos2 = insert(:roster_position, fantasy_team: team)

      attrs = %{
        "roster_positions" => %{
          "0" => %{"id" => pos1.id, "position" => "Flex1"},
          "1" => %{"id" => pos2.id, "position" => "Flex2"}
        }
      }

      conn = patch(conn, fantasy_team_path(conn, :update, team, fantasy_team: attrs))

      [p1, p2] = Repo.all(RosterPosition)

      assert redirected_to(conn) == fantasy_team_path(conn, :show, team.id)
      assert p1.position == "Flex1"
      assert p2.position == "Flex2"
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      conn =
        patch(conn, fantasy_team_path(conn, :update, team.id, fantasy_team: %{team_name: nil}))

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      conn =
        patch(conn, fantasy_team_path(conn, :update, team.id, fantasy_team: %{team_name: "Cubs"}))

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
