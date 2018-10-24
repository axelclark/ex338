defmodule Ex338.HistoricalRecord.StoreTest do
  use Ex338.DataCase, aysnc: true

  alias Ex338.HistoricalRecord.Store

  describe "get_current_all_time_records/0" do
    test "only returns current all time records" do
      all_time = insert(:historical_record, type: "all_time", archived: false)
      insert(:historical_record, type: "season")
      insert(:historical_record, type: "all_time", archived: true)

      [result] = Store.get_current_all_time_records()

      assert result.id == all_time.id
    end
  end

  describe "get_current_season_records/0" do
    test "only returns current single season records" do
      season = insert(:historical_record, type: "season", archived: false)
      insert(:historical_record, type: "all_time")
      insert(:historical_record, type: "season", archived: true)

      [result] = Store.get_current_season_records()

      assert result.id == season.id
    end
  end
end
