defmodule Ex338.TradeRepoTest do
  use Ex338.ModelCase
  alias Ex338.{Trade}

  describe "by_league/2" do
    test "returns trades from a league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "a", fantasy_league: league)
      _other_team = insert(:fantasy_team, team_name: "b",
                                         fantasy_league: other_league)
      player = insert(:fantasy_player)
      other_player = insert(:fantasy_player)
      trade = insert(:trade)
      insert(:trade_line_item, fantasy_team: team,
                                     fantasy_player: player,
                                     trade: trade)
      insert(:trade_line_item, fantasy_team: team,
                                     fantasy_player: other_player,
                                     trade: trade)

      query = Trade |> Trade.by_league(league.id)
      query = from r in query, select: r.inserted_at

      assert Repo.all(query) == [trade.inserted_at]
    end
  end
end
