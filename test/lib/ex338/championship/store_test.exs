defmodule Ex338.Championship.StoreTest do
  use Ex338.ModelCase
  alias Ex338.Championship.Store

  describe "get all/1" do
    test "returns all championships" do
      insert_list(3, :championship)

      result = Store.get_all()

      assert Enum.count(result) == 3
    end
  end

  describe "get_championship_by_league/2" do
    test "returns a championship with assocs by league" do
      league = insert(:fantasy_league)
      championship = insert(:championship)

      result = Store.get_championship_by_league(championship.id, league.id)

      assert result.id == championship.id
    end
  end
end
