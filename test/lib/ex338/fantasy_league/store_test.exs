defmodule Ex338.FantasyLeague.StoreTest do
  use Ex338.ModelCase
  alias Ex338.FantasyLeague

  describe "get_league/1" do
    test "returns league from id" do
      league = insert(:fantasy_league)

      result = FantasyLeague.Store.get(league.id)

      assert result.fantasy_league_name == league.fantasy_league_name
    end
  end
end
