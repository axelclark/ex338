defmodule Ex338.FantasyTeamControllerTest do
  use Ex338.ConnCase

  alias Ex338.{User, FantasyTeam}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all fantasy teams in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      position = insert(:roster_position, position: "Any", fantasy_team: team)

      conn = get conn, fantasy_league_fantasy_team_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Fantasy Teams/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, position.position)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end

  describe "show/2" do
    test "shows fantasy team info and players' table", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, user: conn.assigns.current_user, fantasy_team: team)
      player = insert(:fantasy_player)
      insert(:roster_position, position: "Any", fantasy_team: team,
                                          fantasy_player: player)

      conn = get conn, fantasy_team_path(conn, :show, team.id)

      assert html_response(conn, 200) =~ ~r/Brown/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, conn.assigns.current_user.name)
      assert String.contains?(conn.resp_body, player.player_name)
    end
  end

  describe "edit/2" do
    test "renders a form to change a team name", %{conn: conn} do
      team = insert(:fantasy_team, team_name: "Brown")
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      conn = get conn, fantasy_team_path(conn, :edit, team.id)

      assert html_response(conn, 200) =~ ~r/Update Fantasy Team/
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      team = insert(:fantasy_team, team_name: "Brown")

      conn = get conn, fantasy_team_path(conn, :edit, team.id)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "update/2" do
    test "updates a fantasy team and redirects", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      conn = patch conn, fantasy_team_path(conn, :update, team, fantasy_team: %{team_name: "Cubs"})

      assert redirected_to(conn) == fantasy_team_path(conn, :show, team.id)
      assert Repo.get!(FantasyTeam, team.id).team_name == "Cubs"
    end

    test "does not update and renders errors when invalid", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      insert(:owner, fantasy_team: team, user: conn.assigns.current_user)

      conn = patch conn, fantasy_team_path(conn, :update, team.id,
               fantasy_team: %{team_name: nil})

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not owner", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      conn = patch conn, fantasy_team_path(conn, :update, team.id,
               fantasy_team: %{team_name: "Cubs"})

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
