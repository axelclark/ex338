defmodule Ex338Web.TradeControllerTest do
  use Ex338Web.ConnCase

  setup %{conn: conn} do
    user = %Ex338.User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all trades in a league", %{conn: conn} do
      player = insert(:fantasy_player)

      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "Axel", fantasy_league: league)
      trade = insert(:trade)
      insert(:trade_line_item, trade: trade, gaining_team: team_a,
        losing_team: team_b, fantasy_player: player)

      other_league = insert(:fantasy_league)
      team_c = insert(:fantasy_team, team_name: "Another Team",
        fantasy_league: other_league)
      team_d = insert(:fantasy_team, team_name: "Other Team",
        fantasy_league: other_league)
      other_trade = insert(:trade)
      insert(:trade_line_item, trade: other_trade, gaining_team: team_c,
        losing_team: team_d, fantasy_player: player)

      conn = get conn, fantasy_league_trade_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Trades/
      assert String.contains?(conn.resp_body, team_a.team_name)
      assert String.contains?(conn.resp_body, team_b.team_name)
      assert String.contains?(conn.resp_body, player.player_name)
      refute String.contains?(conn.resp_body, team_c.team_name)
    end
  end
end
