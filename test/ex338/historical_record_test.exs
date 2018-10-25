defmodule Ex338.HistoricalRecordTest do
  use Ex338.DataCase, aysnc: true

  alias Ex338.HistoricalRecord

  describe "all_time_records/1" do
    test "only returns all time records" do
      insert(:historical_record, type: "season")
      all_time = insert(:historical_record, type: "all_time")

      result =
       HistoricalRecord
        |> HistoricalRecord.all_time_records()
        |> Repo.one()

      assert result.id == all_time.id
    end
  end

  describe "changeset/2" do
    @valid_attrs %{
      description: "Most Wins",
      record: "12",
      team: "Brown",
      type: "season",
      archived: "false"
    }
    test "changeset with valid attributes" do
      changeset = HistoricalRecord.changeset(%HistoricalRecord{}, @valid_attrs)
      assert changeset.valid?
    end

    @invalid_attrs %{
      description: " Wins",
      record: "",
      team: "",
      year: "",
      type: "",
      archived: "false"
    }
    test "changeset with invalid attributes" do
      changeset = HistoricalRecord.changeset(%HistoricalRecord{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "current_records/1" do
    test "only returns current records" do
      insert(:historical_record, archived: true)
      current = insert(:historical_record, archived: false)

      result =
       HistoricalRecord
        |> HistoricalRecord.current_records()
        |> Repo.one()

      assert result.id == current.id
    end
  end

  describe "season_records/1" do
    test "only returns single season records" do
      season = insert(:historical_record, type: "season")
      insert(:historical_record, type: "all_time")

      result =
       HistoricalRecord
        |> HistoricalRecord.season_records()
        |> Repo.one()

      assert result.id == season.id
    end
  end
end
