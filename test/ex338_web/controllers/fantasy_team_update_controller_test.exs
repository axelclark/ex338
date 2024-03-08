defmodule Ex338Web.FantasyTeamUpdateControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.DraftQueues.DraftQueue
  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.RosterPositions.RosterPosition

  setup :register_and_log_in_user

  describe "edit/2" do
    test "renders a form to update a team", %{conn: conn} do
      team = insert(:fantasy_team)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      pos = insert(:roster_position, fantasy_team: team)
      queue = insert(:draft_queue, fantasy_team: team)

      conn = get(conn, ~p"/fantasy_teams/#{team.id}/edit")

      assert html_response(conn, 200) =~ ~r/Update Team Info/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, pos.fantasy_player.player_name)
      assert String.contains?(conn.resp_body, queue.fantasy_player.player_name)
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      team = insert(:fantasy_team, team_name: "Brown")

      conn = get(conn, ~p"/fantasy_teams/#{team.id}/edit")

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "update/2" do
    test "updates a fantasy team name and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      conn =
        patch(conn, ~p"/fantasy_teams/#{team.id}", fantasy_team: %{team_name: "Cubs"})

      assert redirected_to(conn) == ~p"/fantasy_teams/#{team.id}"
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

      conn = patch(conn, ~p"/fantasy_teams/#{team.id}", fantasy_team: attrs)

      [q1, q2, canx_q] = Repo.all(DraftQueue)

      assert redirected_to(conn) == ~p"/fantasy_teams/#{team.id}"
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

      conn = patch(conn, ~p"/fantasy_teams/#{team.id}", fantasy_team: attrs)

      [p1, p2] = Repo.all(RosterPosition)

      assert redirected_to(conn) == ~p"/fantasy_teams/#{team.id}"
      assert p1.position == "Flex1"
      assert p2.position == "Flex2"
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      conn = patch(conn, ~p"/fantasy_teams/#{team.id}", fantasy_team: %{team_name: nil})

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "does not update and renders draft queue errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league, max_flex_spots: 1)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      regular_position = insert(:roster_position, fantasy_team: team)
      flex_sport = regular_position.fantasy_player.sports_league

      [add, plyr] = insert_list(2, :fantasy_player, sports_league: flex_sport)
      queue = insert(:draft_queue, fantasy_team: team, fantasy_player: add, order: 1)
      insert(:roster_position, fantasy_team: team, fantasy_player: plyr)

      attrs = %{
        "draft_queues" => %{
          "0" => %{"id" => queue.id, "order" => 2, "status" => "pending"}
        }
      }

      conn = patch(conn, ~p"/fantasy_teams/#{team.id}", fantasy_team: attrs)

      assert html_response(conn, 200) =~ "No flex position available for this player"
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      conn =
        patch(conn, ~p"/fantasy_teams/#{team.id}", fantasy_team: %{team_name: "Cubs"})

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
