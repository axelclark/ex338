defmodule Ex338.HistoricalWinning.StoreTest do
  use Ex338.DataCase, aysnc: true

  alias Ex338.HistoricalWinning.Store

  describe "get_all_winnings/0" do
    test "returns all winnings" do
      insert_list(2, :historical_winning)

      result = Store.get_all_winnings()

      assert Enum.count(result) == 2
    end
  end
end
