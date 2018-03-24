defmodule Ex338.FantasyLeague.StoreTest do
  use Ex338.DataCase
  alias Ex338.FantasyLeague

  describe "get_league/1" do
    test "returns league from id" do
      league = insert(:fantasy_league)

      result = FantasyLeague.Store.get(league.id)

      assert result.fantasy_league_name == league.fantasy_league_name
    end
  end

  describe "list_fantasy_leagues/0" do
    test "returns league from id" do
      insert_list(3, :fantasy_league)

      result = FantasyLeague.Store.list_fantasy_leagues()

      assert Enum.count(result) == 3
    end
  end
end
