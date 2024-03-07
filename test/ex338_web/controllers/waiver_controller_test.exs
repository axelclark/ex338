defmodule Ex338Web.WaiverControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts.User
  alias Ex338.CalendarAssistant
  alias Ex338.RosterPositions.RosterPosition
  alias Ex338.Waivers.Waiver

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "new/2" do
    test "renders a form to submit a waiver", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      sport = insert(:sports_league)
      player_b = insert(:fantasy_player, sports_league: sport)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      insert(:championship, sports_league: sport)

      conn = get(conn, ~p"/fantasy_teams/#{team.id}/waivers/new")

      assert html_response(conn, 200) =~ ~r/Submit a new Waiver/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player_a.player_name)
      assert String.contains?(conn.resp_body, player_b.player_name)
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player_a = insert(:fantasy_player)
      _player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)

      conn = get(conn, ~p"/fantasy_teams/#{team.id}/waivers/new")

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "create/2" do
    test "creates a waiver and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)

      insert(
        :championship,
        sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at: CalendarAssistant.days_from_now(9)
      )

      player_a = insert(:fantasy_player, sports_league: sports_league)
      player_b = insert(:fantasy_player, sports_league: sports_league)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{drop_fantasy_player_id: player_a.id, add_fantasy_player_id: player_b.id}

      conn = post(conn, ~p"/fantasy_teams/#{team.id}/waivers", waiver: attrs)
      result = Repo.get_by!(Waiver, attrs)

      assert result.fantasy_team_id == team.id
      assert result.status == "pending"
      assert redirected_to(conn) == ~p"/fantasy_teams/#{team.id}"
    end

    test "drop only waiver is processed immediately", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)

      insert(
        :championship,
        sports_league: sports_league,
        waiver_deadline_at: CalendarAssistant.days_from_now(1),
        championship_at: CalendarAssistant.days_from_now(9)
      )

      player_a = insert(:fantasy_player, sports_league: sports_league)

      position =
        insert(
          :roster_position,
          fantasy_player: player_a,
          fantasy_team: team
        )

      attrs = %{drop_fantasy_player_id: player_a.id}

      conn = post(conn, ~p"/fantasy_teams/#{team.id}/waivers", waiver: attrs)
      waiver = Repo.get_by!(Waiver, attrs)
      position = Repo.get!(RosterPosition, position.id)

      assert waiver.fantasy_team_id == team.id
      assert waiver.status == "successful"
      assert position.status == "dropped"
      assert redirected_to(conn) == ~p"/fantasy_teams/#{team.id}"
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      sport = insert(:sports_league)
      _player_b = insert(:fantasy_player, sports_league: sport)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      insert(:championship, sports_league: sport)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      invalid_attrs = %{drop_fantasy_player: "", add_fantasy_player_id: ""}

      conn = post(conn, ~p"/fantasy_teams/#{team.id}/waivers", waiver: invalid_attrs)

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{drop_fantasy_player_id: player_a.id, add_fantasy_player_id: player_b.id}

      conn = post(conn, ~p"/fantasy_teams/#{team.id}/waivers", waiver: attrs)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "edit/2" do
    test "renders a form to update a waiver", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      waiver =
        insert(
          :waiver,
          fantasy_team: team,
          drop_fantasy_player: player_a,
          add_fantasy_player: player_b
        )

      conn = get(conn, ~p"/waivers/#{waiver.id}/edit")

      assert html_response(conn, 200) =~ ~r/Update Waiver/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player_b.player_name)
      assert String.contains?(conn.resp_body, "cancelled")
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      waiver = insert(:waiver)

      conn = get(conn, ~p"/waiver_admin/#{waiver.id}/edit")

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "update/2" do
    test "updates a player to drop", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player = insert(:fantasy_player)

      waiver =
        insert(
          :waiver,
          fantasy_team: team,
          drop_fantasy_player: player
        )

      params = %{drop_fantasy_player_id: player.id, status: "cancelled"}

      conn = patch(conn, ~p"/waivers/#{waiver.id}", waiver: params)

      assert Repo.get!(Waiver, waiver.id).status == "cancelled"

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{team.fantasy_league_id}/waivers"
    end

    test "updates a waiver to cancelled", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      waiver =
        insert(
          :waiver,
          fantasy_team: team,
          drop_fantasy_player: player_a
        )

      params = %{drop_fantasy_player_id: player_b.id}

      conn = patch(conn, ~p"/waivers/#{waiver.id}", waiver: params)

      assert Repo.get!(Waiver, waiver.id).drop_fantasy_player_id == player_b.id

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{team.fantasy_league_id}/waivers"
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)

      waiver =
        insert(
          :waiver,
          fantasy_team: team,
          drop_fantasy_player: player_a
        )

      params = %{drop_fantasy_player_id: -1}

      conn = patch(conn, ~p"/waivers/#{waiver.id}", waiver: params)

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      waiver = insert(:waiver)
      params = %{drop_fantasy_player_id: 3}

      conn = patch(conn, ~p"/waivers/#{waiver.id}", waiver: params)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
