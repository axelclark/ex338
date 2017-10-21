defmodule Ex338.Trade.StoreTest do
  use Ex338.DataCase
  alias Ex338.Trade.Store

  describe "all_for_league/2" do
    test "returns only trades from a league with most recent first" do
      player = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "a", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "b", fantasy_league: league)
      team_c = insert(:fantasy_team, team_name: "c", fantasy_league: league)

      trade1 = insert(:trade)
      insert(:trade_line_item, gaining_team: team, losing_team: team_b,
       fantasy_player: player, trade: trade1)

      trade2 = insert(:trade)
      insert(:trade_line_item, gaining_team: team_b, losing_team: team_c,
       fantasy_player: player_b, trade: trade2)

      league_b = insert(:fantasy_league)
      team_d = insert(:fantasy_team, team_name: "d", fantasy_league: league_b)
      team_e = insert(:fantasy_team, team_name: "e", fantasy_league: league_b)
      other_trade = insert(:trade)
      insert(:trade_line_item, gaining_team: team_e, losing_team: team_d,
       fantasy_player: player_b, trade: other_trade)

      [result_a, result_b] = Store.all_for_league(league.id)

      assert result_a.id == trade2.id
      assert result_b.id == trade1.id
    end
  end

  describe "process_trade/2" do
    test "updates repo with successful trade " do
      league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      trade = insert(:trade)
      insert(:trade_line_item, gaining_team: team_b, losing_team: team_a,
       fantasy_player: player_a, trade: trade)
      insert(:trade_line_item, gaining_team: team_a, losing_team: team_b,
       fantasy_player: player_b, trade: trade)

      params = %{"status" => "Approved"}

      {:ok, %{trade: trade}} = Store.process_trade(trade.id, params)

      positions = Repo.all(Ex338.RosterPosition)
      assert trade.status == "Approved"
      assert Enum.count(positions) == 4
    end

    test "returns error if a position is not found" do
      league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)

      trade = insert(:trade)
      insert(:trade_line_item, gaining_team: team_b, losing_team: team_a,
       fantasy_player: player_a, trade: trade)
      insert(:trade_line_item, gaining_team: team_a, losing_team: team_b,
       fantasy_player: player_b, trade: trade)

      params = %{"status" => "Approved"}

      {:error, error} = Store.process_trade(trade.id, params)

      assert error == "One or more positions not found"
    end
  end

  describe "find!/1" do
    test "returns a Trade with assocs loaded" do
      trade = insert(:trade)
      line_item = insert(:trade_line_item, trade: trade)

      result = %{trade_line_items: [item]} = Store.find!(trade.id)

      assert result.id == trade.id
      assert item.id == line_item.id
    end
  end
end
