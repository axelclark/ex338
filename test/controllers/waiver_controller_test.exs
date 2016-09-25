defmodule Ex338.WaiverControllerTest do
  use Ex338.ConnCase
  alias Ex338.{Waiver, User}

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
      other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      insert(:waiver, fantasy_team: team, add_fantasy_player: player,
                      status: "successful")
      insert(:waiver, fantasy_team: other_team, add_fantasy_player: player,
                      status: "successful")

      conn = get conn, fantasy_league_waiver_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Waivers/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player.player_name)
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
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{fantasy_team_id: team.id, drop_fantasy_player_id: player_a.id,
               add_fantasy_player_id: player_b.id}

      conn = post conn, fantasy_team_waiver_path(conn, :create, team.id, waiver: attrs)
      result = Repo.get_by!(Waiver, attrs)

      assert result.fantasy_team_id == team.id
      assert result.status == "pending"
      assert redirected_to(conn) == fantasy_team_path(conn, :show, team.id)
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)
      player_a = insert(:fantasy_player)
      _player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      invalid_attrs = %{fantasy_team_id: team.id, add_fantasy_player_id: -5}

      conn = post conn, fantasy_team_waiver_path(conn, :create, team.id, waiver: invalid_attrs)

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{fantasy_team_id: team.id, drop_fantasy_player_id: player_a.id,
               add_fantasy_player_id: player_b.id}

      conn = post conn, fantasy_team_waiver_path(conn, :create, team.id, waiver: attrs)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
