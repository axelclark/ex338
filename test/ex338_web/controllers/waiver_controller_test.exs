defmodule Ex338Web.WaiverControllerTest do
  use Ex338Web.ConnCase
  alias Ex338.{Waiver, User, RosterPosition, CalendarAssistant}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all waivers in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player = insert(:fantasy_player)
      player2 = insert(:fantasy_player)
      other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      insert(:waiver, fantasy_team: team, add_fantasy_player: player,
                      status: "successful")
      insert(:waiver, fantasy_team: other_team, add_fantasy_player: player,
                      status: "successful")
      insert(:waiver, fantasy_team: team, add_fantasy_player: player2,
                      status: "pending")

      conn = get conn, fantasy_league_waiver_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Waivers/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player.player_name)
      assert String.contains?(conn.resp_body, player2.player_name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end

  describe "new/2" do
    test "renders a form to submit a waiver", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      _player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)

      conn = get conn, fantasy_team_waiver_path(conn, :new, team.id)

      assert html_response(conn, 200) =~ ~r/Submit New Waiver/
      assert String.contains?(conn.resp_body, team.team_name)
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player_a = insert(:fantasy_player)
      _player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)

      conn = get conn, fantasy_team_waiver_path(conn, :new, team.id)

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
      insert(:championship, sports_league: sports_league,
       waiver_deadline_at: CalendarAssistant.days_from_now(1),
       championship_at:    CalendarAssistant.days_from_now(9))
      player_a = insert(:fantasy_player, sports_league: sports_league)
      player_b = insert(:fantasy_player, sports_league: sports_league)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{drop_fantasy_player_id: player_a.id,
                add_fantasy_player_id: player_b.id}

      conn = post conn, fantasy_team_waiver_path(conn, :create, team.id,
                                                 waiver: attrs)
      result = Repo.get_by!(Waiver, attrs)

      assert result.fantasy_team_id == team.id
      assert result.status == "pending"
      assert redirected_to(conn) == fantasy_team_path(conn, :show, team.id)
    end

    test "drop only waiver is processed immediately", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      insert(:championship, sports_league: sports_league,
       waiver_deadline_at: CalendarAssistant.days_from_now(1),
       championship_at:    CalendarAssistant.days_from_now(9))
      player_a = insert(:fantasy_player, sports_league: sports_league)
      position = insert(:roster_position, fantasy_player: player_a,
                                          fantasy_team: team)
      attrs = %{drop_fantasy_player_id: player_a.id}

      conn = post conn, fantasy_team_waiver_path(conn, :create, team.id,
                                                 waiver: attrs)
      waiver   = Repo.get_by!(Waiver, attrs)
      position = Repo.get!(RosterPosition, position.id)

      assert waiver.fantasy_team_id == team.id
      assert waiver.status == "successful"
      assert position.status == "dropped"
      assert redirected_to(conn) == fantasy_team_path(conn, :show, team.id)
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      _player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      invalid_attrs = %{drop_fantasy_player: "", add_fantasy_player_id: ""}

      conn = post conn, fantasy_team_waiver_path(conn, :create, team.id,
                                                 waiver: invalid_attrs)

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{drop_fantasy_player_id: player_a.id,
                add_fantasy_player_id: player_b.id}

      conn = post conn, fantasy_team_waiver_path(conn, :create, team.id,
                                                 waiver: attrs)

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
      waiver = insert(:waiver, fantasy_team: team,
                               drop_fantasy_player: player_a,
                               add_fantasy_player:  player_b)

      conn = get conn, waiver_path(conn, :edit, waiver.id)

      assert html_response(conn, 200) =~ ~r/Update Player to Drop/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player_b.player_name)
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      waiver = insert(:waiver)

      conn = get conn, waiver_admin_path(conn, :edit, waiver.id)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "update/2" do
    test "updates a player to drop", %{conn: conn} do
      league = insert(:fantasy_league)
      team   = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      waiver = insert(:waiver, fantasy_team: team,
                               drop_fantasy_player: player_a)
      params = %{drop_fantasy_player_id: player_b.id}

      conn = patch conn, waiver_path(conn, :update, waiver.id, waiver: params)

      assert Repo.get!(Waiver, waiver.id).drop_fantasy_player_id == player_b.id
      assert redirected_to(conn) == fantasy_league_waiver_path(conn, :index,
                                      team.fantasy_league_id)
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team   = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      waiver = insert(:waiver, fantasy_team: team,
                               drop_fantasy_player: player_a)
      params = %{drop_fantasy_player_id: -1}

      conn = patch conn, waiver_path(conn, :update, waiver.id, waiver: params)

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      waiver = insert(:waiver)
      params = %{drop_fantasy_player_id: 3}

      conn = patch conn, waiver_path(conn, :update, waiver.id, waiver: params)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
