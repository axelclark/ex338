defmodule Ex338.HistoricalRecord.StoreTest do
  use Ex338.DataCase, aysnc: true

  alias Ex338.HistoricalRecord.Store

  describe "get_current_all_time_records/0" do
    test "only returns current all time records" do
      _all_time3 = insert(:historical_record, type: "all_time", archived: false, order: 3.0)
      _all_time1 = insert(:historical_record, type: "all_time", archived: false, order: 1.0)
      _all_time2 = insert(:historical_record, type: "all_time", archived: false, order: 2.0)
      insert(:historical_record, type: "season", order: 4.0)
      insert(:historical_record, type: "all_time", archived: true, order: 5.0)

      results = Store.get_current_all_time_records()

      assert Enum.map(results, & &1.order) == [1.0, 2.0, 3.0]
    end
  end

  describe "get_current_season_records/0" do
    test "only returns current single season records" do
      _season1 = insert(:historical_record, type: "season", archived: false, order: 3.0)
      _season2 = insert(:historical_record, type: "season", archived: false, order: 1.0)
      _season3 = insert(:historical_record, type: "season", archived: false, order: 2.0)
      insert(:historical_record, type: "all_time", order: 4.0)
      insert(:historical_record, type: "season", archived: true, order: 5.0)

      results = Store.get_current_season_records()

      assert Enum.map(results, & &1.order) == [1.0, 2.0, 3.0]
    end
  end
end
