defmodule Ex338.TradeControllerTest do
  use Ex338.ConnCase

  describe "index/2" do
    test "lists all trades in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player = insert(:fantasy_player)
      other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      trade = insert(:trade)
      insert(:trade_line_item, trade: trade, fantasy_team: team,
                                     fantasy_player: player)
      other_trade = insert(:trade)
      insert(:trade_line_item, trade: other_trade, fantasy_team: other_team,
                                     fantasy_player: player)

      conn = get conn, fantasy_league_trade_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Trades/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player.player_name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end
end
