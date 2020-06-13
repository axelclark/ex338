defmodule Ex338Web.FantasyTeamControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.{Accounts.User, FantasyTeams.FantasyTeam, DraftQueue, RosterPositions.RosterPosition}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all fantasy teams in a fantasy league", %{conn: conn} do
      league = insert(:fantasy_league)
      teams = insert_list(2, :fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      insert(:championship, sports_league: sport)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:fantasy_player, sports_league: sport)

      ir_player = insert(:fantasy_player, sports_league: sport)

      insert(
        :roster_position,
        fantasy_team: hd(teams),
        fantasy_player: ir_player,
        status: "injured_reserve"
      )

      conn = get(conn, fantasy_league_fantasy_team_path(conn, :index, league.id))

      assert html_response(conn, 200) =~ ~r/Fantasy Teams/
    end

    test "shows fantasy team championship with events results", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, user: conn.assigns.current_user, fantasy_team: team)

      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position, fantasy_team: team, fantasy_player: player)
      insert(:champ_with_events_result, fantasy_team: team, points: 8, championship: championship)

      conn = get(conn, fantasy_league_fantasy_team_path(conn, :index, league.id))

      assert html_response(conn, 200) =~ ~r/Brown/
      assert String.contains?(conn.resp_body, championship.title)
      assert String.contains?(conn.resp_body, "8")
    end

    test "shows fantasy team slot results", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)
      championship2 = insert(:championship, sports_league: sport)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)

      pos = insert(:roster_position, fantasy_team: team, fantasy_player: player)

      _slot1 =
        insert(
          :championship_slot,
          roster_position: pos,
          championship: championship,
          slot: 1
        )

      _slot2 =
        insert(
          :championship_slot,
          roster_position: pos,
          championship: championship2,
          slot: 1
        )

      _champ_result1 =
        insert(
          :championship_result,
          championship: championship,
          fantasy_player: player,
          points: 8,
          rank: 1
        )

      _champ_result2 =
        insert(
          :championship_result,
          championship: championship2,
          fantasy_player: player,
          points: 5,
          rank: 2
        )

      conn = get(conn, fantasy_league_fantasy_team_path(conn, :index, league.id))

      assert html_response(conn, 200) =~ ~r/Slot/
      assert String.contains?(conn.resp_body, championship.sports_league.abbrev)
      assert String.contains?(conn.resp_body, "13")
    end
  end

  describe "show/2" do
    test "shows fantasy team info and players' table", %{conn: conn} do
      league = insert(:fantasy_league)

      team =
        insert(
          :fantasy_team,
          team_name: "Brown",
          fantasy_league: league,
          winnings_received: 75.00,
          dues_paid: 100.00,
          winnings_adj: 10.00
        )

      insert(:owner, user: conn.assigns.current_user, fantasy_team: team)

      sport = insert(:sports_league)
      insert(:championship, sports_league: sport)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:fantasy_player, sports_league: sport)

      unassigned_player = insert(:fantasy_player, sports_league: sport)
      dropped_player = insert(:fantasy_player, sports_league: sport)
      ir_player = insert(:fantasy_player, sports_league: sport)

      insert(
        :roster_position,
        position: "Unassigned",
        fantasy_team: team,
        fantasy_player: unassigned_player
      )

      insert(
        :roster_position,
        fantasy_team: team,
        fantasy_player: dropped_player,
        status: "dropped"
      )

      insert(
        :roster_position,
        fantasy_team: team,
        fantasy_player: ir_player,
        status: "injured_reserve"
      )

      conn = get(conn, fantasy_team_path(conn, :show, team.id))

      assert html_response(conn, 200) =~ ~r/Brown/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, conn.assigns.current_user.name)
      assert String.contains?(conn.resp_body, unassigned_player.player_name)
      assert String.contains?(conn.resp_body, ir_player.player_name)
      assert String.contains?(conn.resp_body, "75")
      assert String.contains?(conn.resp_body, "100")
      refute String.contains?(conn.resp_body, dropped_player.player_name)
    end

    test "shows fantasy team championship with events results", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, user: conn.assigns.current_user, fantasy_team: team)

      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position, fantasy_team: team, fantasy_player: player)
      insert(:champ_with_events_result, fantasy_team: team, points: 8, championship: championship)

      conn = get(conn, fantasy_team_path(conn, :show, team.id))

      assert html_response(conn, 200) =~ ~r/Brown/
      assert String.contains?(conn.resp_body, championship.title)
      assert String.contains?(conn.resp_body, "8")
    end

    test "shows fantasy team slot results", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)
      championship2 = insert(:championship, sports_league: sport)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)

      pos = insert(:roster_position, fantasy_team: team, fantasy_player: player)

      _slot1 =
        insert(
          :championship_slot,
          roster_position: pos,
          championship: championship,
          slot: 1
        )

      _slot2 =
        insert(
          :championship_slot,
          roster_position: pos,
          championship: championship2,
          slot: 1
        )

      _champ_result1 =
        insert(
          :championship_result,
          championship: championship,
          fantasy_player: player,
          points: 8,
          rank: 1
        )

      _champ_result2 =
        insert(
          :championship_result,
          championship: championship2,
          fantasy_player: player,
          points: 5,
          rank: 2
        )

      conn = get(conn, fantasy_team_path(conn, :show, team.id))

      assert html_response(conn, 200) =~ ~r/Slot/
      assert String.contains?(conn.resp_body, championship.sports_league.abbrev)
      assert String.contains?(conn.resp_body, "13")
    end

    test "shows draft queue for team when user is owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, user: conn.assigns.current_user, fantasy_team: team)
      queue = insert(:draft_queue, fantasy_team: team)

      conn = get(conn, fantasy_team_path(conn, :show, team.id))

      assert html_response(conn, 200) =~ ~r/Brown/
      assert String.contains?(conn.resp_body, queue.fantasy_player.player_name)
    end

    test "does not show draft queue when user not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      queue = insert(:draft_queue, fantasy_team: team)

      conn = get(conn, fantasy_team_path(conn, :show, team.id))

      assert html_response(conn, 200) =~ ~r/Brown/
      refute String.contains?(conn.resp_body, queue.fantasy_player.player_name)
    end

    test "shows future picks including original team", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: league)
      insert(:future_pick, current_team: team, original_team: other_team)

      conn = get(conn, fantasy_team_path(conn, :show, team.id))

      assert String.contains?(conn.resp_body, other_team.team_name)
    end
  end

  describe "edit/2" do
    test "renders a form to update a team", %{conn: conn} do
      team = insert(:fantasy_team)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      pos = insert(:roster_position, fantasy_team: team)
      queue = insert(:draft_queue, fantasy_team: team)

      conn = get(conn, fantasy_team_path(conn, :edit, team.id))

      assert html_response(conn, 200) =~ ~r/Update Fantasy Team/
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
