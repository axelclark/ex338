defmodule Ex338Web.Api.V1.TradeControllerTest do
  use Ex338Web.ConnCase

  describe "GET /api/v1/fantasy_leagues/:fantasy_league_id/trades" do
    test "returns trades for a league", %{conn: conn} do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league, waiver_position: 1)
      team_b = insert(:fantasy_team, fantasy_league: league, waiver_position: 2)
      player = insert(:fantasy_player)

      trade = insert(:trade, status: "Pending")

      insert(:trade_line_item,
        trade: trade,
        gaining_team: team_a,
        losing_team: team_b,
        fantasy_player: player
      )

      conn = get(conn, ~p"/api/v1/fantasy_leagues/#{league.id}/trades")

      assert %{"trades" => trades} = json_response(conn, 200)
      assert length(trades) == 1
      [trade_data] = trades
      assert trade_data["status"] == "Pending"
      assert is_list(trade_data["trade_line_items"])
    end
  end
end
