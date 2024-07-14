defmodule Ex338Web.InjuredReserveControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.CalendarAssistant
  alias Ex338.InjuredReserves.InjuredReserve

  describe "index/2" do
    setup :register_and_log_in_user

    test "lists all injured reserve transactions in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player = insert(:fantasy_player)

      other_team =
        insert(
          :fantasy_team,
          team_name: "Another Team",
          fantasy_league: other_league
        )

      insert(
        :injured_reserve,
        fantasy_team: team,
        injured_player: player,
        status: "approved"
      )

      insert(
        :injured_reserve,
        fantasy_team: other_team,
        injured_player: player,
        status: "approved"
      )

      conn = get(conn, ~p"/fantasy_leagues/#{league.id}/injured_reserves")

      assert html_response(conn, 200) =~ ~r/Injured Reserve Actions/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player.player_name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end

  describe "new/2" do
    setup :register_and_log_in_user

    test "renders a form to submit an injured reserve", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team, status: "active")
      sport = insert(:sports_league)
      player_b = insert(:fantasy_player, sports_league: sport)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      insert(:championship, sports_league: sport)

      other_team = insert(:fantasy_team, fantasy_league: league)
      other_player = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position,
        fantasy_player: other_player,
        fantasy_team: other_team,
        status: "active"
      )

      conn = get(conn, ~p"/fantasy_teams/#{team.id}/injured_reserves/new")

      assert html_response(conn, 200) =~ ~r/Submit a new Injured Reserve/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player_a.player_name)
      assert String.contains?(conn.resp_body, player_b.player_name)
      refute String.contains?(conn.resp_body, other_player.player_name)
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)

      conn = get(conn, ~p"/fantasy_teams/#{team.id}/injured_reserves/new")

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "create/2" do
    setup :register_and_log_in_user

    test "creates an injured reserve and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)

      insert(
        :championship,
        sports_league: sports_league,
        championship_at: CalendarAssistant.days_from_now(1)
      )

      player_a = insert(:fantasy_player, sports_league: sports_league)
      player_b = insert(:fantasy_player, sports_league: sports_league)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{injured_player_id: player_a.id, replacement_player_id: player_b.id}

      conn =
        post(
          conn,
          ~p"/fantasy_teams/#{team.id}/injured_reserves?#{[injured_reserve: attrs]}"
        )

      result = Repo.get_by!(InjuredReserve, attrs)

      assert result.fantasy_team_id == team.id
      assert result.status == :submitted
      assert redirected_to(conn) == ~p"/fantasy_teams/#{team.id}"
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)

      insert(
        :championship,
        sports_league: sports_league,
        championship_at: CalendarAssistant.days_from_now(1)
      )

      player_a = insert(:fantasy_player, sports_league: sports_league)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      invalid_attrs = %{injured_player_id: player_a.id, replacement_player_id: nil}

      conn =
        post(
          conn,
          ~p"/fantasy_teams/#{team.id}/injured_reserves?#{[injured_reserve: invalid_attrs]}"
        )

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)

      player_a = insert(:fantasy_player, sports_league: sports_league)
      player_b = insert(:fantasy_player, sports_league: sports_league)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{injured_player_id: player_a.id, replacement_player_id: player_b.id}

      conn =
        post(
          conn,
          ~p"/fantasy_teams/#{team.id}/injured_reserves?#{[injured_reserve: attrs]}"
        )

      assert Flash.get(conn.assigns.flash, :error) == "You can't access that page!"
      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "update/2 as admin" do
    setup :register_and_log_in_admin

    test "processes an approved IR claim", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a)

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b,
          status: "submitted"
        )

      conn =
        patch(
          conn,
          Routes.fantasy_league_injured_reserve_path(conn, :update, league.id, ir.id, %{
            "injured_reserve" => %{"status" => "approved"}
          })
        )

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{team.fantasy_league_id}/injured_reserves"

      assert Repo.get!(InjuredReserve, ir.id).status == :approved
    end

    test "handles error", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b,
          status: "submitted"
        )

      conn =
        patch(
          conn,
          Routes.fantasy_league_injured_reserve_path(conn, :update, league.id, ir.id, %{
            "injured_reserve" => %{"status" => "approved"}
          })
        )

      assert Flash.get(conn.assigns.flash, :error) == "No roster position found for IR."
      assert Repo.get!(InjuredReserve, ir.id).status == :submitted
    end
  end

  describe "update/2 as user" do
    setup :register_and_log_in_user

    test "redirects to root if user is not admin", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      ir = insert(:injured_reserve, fantasy_team: team)

      conn =
        patch(
          conn,
          Routes.fantasy_league_injured_reserve_path(conn, :update, league.id, ir.id, %{
            "injured_reserve" => %{"status" => "approved"}
          })
        )

      assert Flash.get(conn.assigns.flash, :error) == "You are not authorized"
      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
