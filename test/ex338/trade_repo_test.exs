defmodule Ex338.TradeRepoTest do
  use Ex338.DataCase
  alias Ex338.{Trade}

  describe "by_league/2" do
    test "returns trades from a league" do
      player = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "a", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "b", fantasy_league: league)
      trade = insert(:trade)
      insert(:trade_line_item, gaining_team: team, losing_team: team_b,
       fantasy_player: player, trade: trade)

      league_b = insert(:fantasy_league)
      team_c = insert(:fantasy_team, team_name: "c", fantasy_league: league_b)
      team_d = insert(:fantasy_team, team_name: "d", fantasy_league: league_b)
      other_trade = insert(:trade)
      insert(:trade_line_item, gaining_team: team_c, losing_team: team_d,
       fantasy_player: player_b, trade: other_trade)

      result =
        Trade
        |> Trade.by_league(league.id)
        |> Repo.one

      assert result.id == trade.id
    end
  end

  describe "preload_assocs/1" do
    test "returns trade with assocs" do
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)
      team_a = insert(:fantasy_team)
      team_b = insert(:fantasy_team)
      team_c = insert(:fantasy_team)
      user = insert(:user)
      trade = insert(:trade)
      insert(:trade_line_item, trade: trade, fantasy_player: player,
        gaining_team: team_a, losing_team: team_b)
      insert(:trade_vote, trade: trade, fantasy_team: team_c, user: user)

      %{trade_line_items: [line_item], trade_votes: [vote]} =
        Trade
        |> Trade.preload_assocs
        |> Repo.one

      assert line_item.fantasy_player.sports_league.id == sport.id
      assert line_item.gaining_team.id == team_a.id
      assert line_item.losing_team.id == team_b.id
      assert vote.fantasy_team.id == team_c.id
    end
  end

  describe "newest_first/1" do
    test "returns newest trade first" do
      _trade_a = insert(:trade)
      trade_b = insert(:trade)

      [result_1, _result_2] =
        Trade
        |> Trade.newest_first
        |> Repo.all

      assert result_1.id == trade_b.id
    end
  end
end
