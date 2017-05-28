defmodule Ex338.FantasyLeagueControllerTest do
  use Ex338.ConnCase

  setup %{conn: conn} do
    user = %Ex338.User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "show/2" do
    test "login is required" do
      conn = %Plug.Conn{}
      league = insert(:fantasy_league)

      conn = get conn, fantasy_league_path(conn, :show, league.id)

      assert html_response(conn, 200) =~ "action=\"/sessions\""
      assert conn.resp_body =~ "Email"
      assert conn.resp_body =~ "Password"
    end
  end

  describe "show/2" do
    test "shows league and lists all fantasy teams", %{conn: conn} do
      league = insert(:fantasy_league)
      team_1 = insert(:fantasy_team, team_name: "Brown", fantasy_league: league,
       winnings_adj: 20.00)
      team_2 = insert(:fantasy_team, team_name: "Axel", fantasy_league: league,
       dues_paid: 100.00)
      player = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_1, fantasy_player: player,
        status: "active")
      insert(:championship_result, points: 8, rank: 1, fantasy_player: player)
      insert(:champ_with_events_result, points: 8.0, rank: 1, winnings: 25.00,
        fantasy_team: team_1)

      conn = get conn, fantasy_league_path(conn, :show, league.id)

      assert html_response(conn, 200) =~ ~r/Fantasy League/
      assert String.contains?(conn.resp_body, team_1.team_name)
      assert String.contains?(conn.resp_body, team_2.team_name)
      assert String.contains?(conn.resp_body, "100")
      assert String.contains?(conn.resp_body, "16.0")
      assert String.contains?(conn.resp_body, "70.0")
    end
  end
end
