defmodule Ex338Web.PageControllerTest do
  use Ex338Web.ConnCase
  import Phoenix.LiveViewTest

  describe "GET /" do
    test "displays title", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "League Announcements"
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

      assert html_response(conn, 200) =~ ~r/338 Challenge/
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

  test "GET /rules from 2017", %{conn: conn} do
    user = insert(:user)
    conn = assign(conn, :current_user, user)
    league = insert(:fantasy_league, year: 2017, draft_method: "redraft")

    conn = get(conn, "/rules", %{"fantasy_league_id" => league.id})

    assert html_response(conn, 200) =~ "338 Rules"
  end

  test "GET /rules from 2018", %{conn: conn} do
    user = insert(:user)
    conn = assign(conn, :current_user, user)
    league = insert(:fantasy_league, year: 2018, draft_method: "redraft")

    conn = get(conn, "/rules", %{"fantasy_league_id" => league.id})

    assert html_response(conn, 200) =~ "338 Rules"
  end

  test "GET /rules from 2019", %{conn: conn} do
    user = insert(:user)
    conn = assign(conn, :current_user, user)
    league = insert(:fantasy_league, year: 2019, draft_method: "redraft")

    conn = get(conn, "/rules", %{"fantasy_league_id" => league.id})

    assert html_response(conn, 200) =~ "338 Rules"
  end

  test "GET /rules from 2020", %{conn: conn} do
    user = insert(:user)
    conn = assign(conn, :current_user, user)
    league = insert(:fantasy_league, year: 2020)
    team = insert(:fantasy_team, fantasy_league: league)
    insert(:owner, fantasy_team: team, user: user)

    conn = assign(conn, :live_module, Ex338Web.RulesLive)
    {:ok, view, html} = live(conn, "/rules?fantasy_league_id=#{league.id}")

    assert html =~ "338 Rules"
    assert html =~ "Accept Rules"
    refute html =~ "Accepted 2020 Rules!"

    live_view = render_change(view, :accept)

    refute live_view =~ "Accept Rules"
    assert live_view =~ "Accepted 2020 Rules!"
  end

  test "GET /keeper_rules from 2020", %{conn: conn} do
    user = insert(:user)
    conn = assign(conn, :current_user, user)
    league = insert(:fantasy_league, year: 2020, draft_method: "keeper")

    conn = get(conn, "/rules", %{"fantasy_league_id" => league.id})

    assert html_response(conn, 200) =~ "338 Keeper Rules"
  end

  test "GET /rules from 2022 without user", %{conn: conn} do
    league = insert(:fantasy_league, year: 2022, draft_method: "redraft")

    conn = get(conn, "/rules", %{"fantasy_league_id" => league.id})

    assert html_response(conn, 200) =~ "338 Rules"
  end

  test "GET /rules from 2023 without user", %{conn: conn} do
    league = insert(:fantasy_league, year: 2023, draft_method: "redraft")

    conn = get(conn, "/rules", %{"fantasy_league_id" => league.id})

    assert html_response(conn, 200) =~ "338 Rules"
  end

  test "GET /keeper_rules from 2023", %{conn: conn} do
    user = insert(:user)
    conn = assign(conn, :current_user, user)
    league = insert(:fantasy_league, year: 2023, draft_method: "keeper")

    conn = get(conn, "/rules", %{"fantasy_league_id" => league.id})

    assert html_response(conn, 200) =~ "338 Rules"
  end

  test "GET /rules from 2024 without user", %{conn: conn} do
    league = insert(:fantasy_league, year: 2024, draft_method: "redraft")

    conn = get(conn, "/rules", %{"fantasy_league_id" => league.id})

    assert html_response(conn, 200) =~ "338 Rules"
  end

  test "GET /keeper_rules from 2024", %{conn: conn} do
    user = insert(:user)
    conn = assign(conn, :current_user, user)
    league = insert(:fantasy_league, year: 2024, draft_method: "keeper")

    conn = get(conn, "/rules", %{"fantasy_league_id" => league.id})

    assert html_response(conn, 200) =~ "338 Rules"
  end
end
