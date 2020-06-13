defmodule Ex338Web.ArchivedLeagueControllerTest do
  use Ex338Web.ConnCase

  setup %{conn: conn} do
    user = %Ex338.Accounts.User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "show/2" do
    test "lists all archived leagues", %{conn: conn} do
      league = insert(:fantasy_league, navbar_display: "archived")
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

      league2 = insert(:fantasy_league, navbar_display: "archived")
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

      conn = get(conn, archived_league_path(conn, :index))

      assert html_response(conn, 200) =~ ~r/Past Fantasy League Results/
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
end
