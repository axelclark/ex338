defmodule Ex338Web.PageControllerTest do
  use Ex338Web.ConnCase

  setup %{conn: conn} do
    user = %Ex338.User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "GET /" do
    test "login is required" do
      conn = %Plug.Conn{}
      league = insert(:fantasy_league)

      conn = get(conn, fantasy_league_path(conn, :show, league.id))

      assert html_response(conn, 302) =~ "/sessions/new"
    end

    test "displays title", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Welcome to the 338 Challenge!"
    end

    test "Loads leagues into assigns", %{conn: conn} do
      league = insert(:fantasy_league)
      conn = get(conn, "/")
      assert conn.assigns.leagues == [league]
    end

    test "displays historical records & winnings", %{conn: conn} do
      insert(:historical_record,
        team: "Brown",
        description: "Most Wins",
        record: "13",
        type: "season",
        year: "2013"
      )

      insert(:historical_record,
        team: "Axel",
        description: "Most Championships",
        record: "11",
        type: "all_time"
      )

      insert(:historical_winning, team: "Jim", amount: 2113)

      conn = get(conn, "/")

      assert html_response(conn, 200) =~ "Most Wins"
      assert String.contains?(conn.resp_body, "Most Championships")
      assert String.contains?(conn.resp_body, "$2,113")
    end

    test "displays current standings", %{conn: conn} do
      league = insert(:fantasy_league, navbar_display: "primary")
      player = insert(:fantasy_player)

      team_1 = insert(:fantasy_team, fantasy_league: league, winnings_adj: 20.00)
      insert(:roster_position, fantasy_team: team_1, fantasy_player: player)
      insert(:championship_result, points: 8, rank: 1, fantasy_player: player)

      insert(
        :champ_with_events_result,
        points: 8.0,
        rank: 1,
        winnings: 25.00,
        fantasy_team: team_1
      )

      team_1_points = "16.0"
      team_1_winnings = "$70"

      team_2 = insert(:fantasy_team, fantasy_league: league)

      league2 = insert(:fantasy_league, navbar_display: "primary")
      player2 = insert(:fantasy_player)

      team_3 = insert(:fantasy_team, fantasy_league: league2)
      insert(:roster_position, fantasy_team: team_3, fantasy_player: player2)
      insert(:championship_result, points: 5, rank: 2, fantasy_player: player2)

      team_4 = insert(:fantasy_team, fantasy_league: league2, winnings_adj: 50.00)

      insert(
        :champ_with_events_result,
        points: 8.0,
        rank: 1,
        winnings: 25.00,
        fantasy_team: team_4
      )

      team_4_points = "8.0"
      team_4_winnings = "$75"

      conn = get(conn, "/")

      assert html_response(conn, 200) =~ ~r/Current Standings/
      assert String.contains?(conn.resp_body, team_1.team_name)
      assert String.contains?(conn.resp_body, team_2.team_name)
      assert String.contains?(conn.resp_body, team_3.team_name)
      assert String.contains?(conn.resp_body, team_4.team_name)
      assert String.contains?(conn.resp_body, team_1_points)
      assert String.contains?(conn.resp_body, team_1_winnings)
      assert String.contains?(conn.resp_body, team_4_points)
      assert String.contains?(conn.resp_body, team_4_winnings)
    end
  end

  test "GET /2017_rules", %{conn: conn} do
    conn = get(conn, "/2017_rules")
    assert html_response(conn, 200) =~ "338 Rules"
  end

  test "GET /2018_rules", %{conn: conn} do
    conn = get(conn, "/2018_rules")
    assert html_response(conn, 200) =~ "338 Rules"
  end

  test "GET /2019_rules", %{conn: conn} do
    conn = get(conn, "/2019_rules")
    assert html_response(conn, 200) =~ "338 Rules"
  end
end
