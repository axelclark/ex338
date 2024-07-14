defmodule Ex338Web.FantasyLeagueLive.ShowTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

  describe "show/2" do
    test "shows league and lists all fantasy teams", %{conn: conn} do
      league = insert(:fantasy_league)

      team_1 =
        insert(:fantasy_team, team_name: "Brown", fantasy_league: league, winnings_adj: 20.00)

      team_2 = insert(:fantasy_team, team_name: "Axel", fantasy_league: league, dues_paid: 100.00)
      player = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_1, fantasy_player: player, status: "active")
      insert(:championship_result, points: 8, rank: 1, fantasy_player: player)

      insert(
        :champ_with_events_result,
        points: 8.0,
        rank: 1,
        winnings: 25.00,
        fantasy_team: team_1
      )

      {:ok, _view, html} = live(conn, ~p"/fantasy_leagues/#{league.id}")

      assert html =~ "Standings"
      assert html =~ team_1.team_name
      assert html =~ team_2.team_name
      assert html =~ "100"
      assert html =~ "16.0"
      assert html =~ "$70"
    end
  end
end
