defmodule Ex338.RosterTransactionRepoTest do
  use Ex338.ModelCase
  alias Ex338.{RosterTransaction}

  describe "by_league/2" do
    test "returns roster transactions from a league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "a", fantasy_league: league)
      other_team = insert(:fantasy_team, team_name: "b", 
                                         fantasy_league: other_league)
      player = insert(:fantasy_player)
      other_player = insert(:fantasy_player)
      roster_transaction = insert(:roster_transaction)
      insert(:transaction_line_item, fantasy_team: team, 
                                     fantasy_player: player,
                                     roster_transaction: roster_transaction)
      insert(:transaction_line_item, fantasy_team: team, 
                                     fantasy_player: other_player,
                                     roster_transaction: roster_transaction)

      query = RosterTransaction |> RosterTransaction.by_league(league.id)
      query = from r in query, select: r.roster_transaction_on

      assert Repo.all(query) == [roster_transaction.roster_transaction_on] 
    end
  end
end
