defmodule Ex338.HistoricalWinningTest do
  use Ex338.DataCase, aysnc: true

  alias Ex338.HistoricalWinning

  describe "changeset/2" do
    @valid_attrs %{
      team: "Brown",
      amount: 213
    }
    test "changeset with valid attributes" do
      changeset = HistoricalWinning.changeset(%HistoricalWinning{}, @valid_attrs)
      assert changeset.valid?
    end

    @invalid_attrs %{
      team: "",
      amount: 0
    }
    test "changeset with invalid attributes" do
      changeset = HistoricalWinning.changeset(%HistoricalWinning{}, @invalid_attrs)
      refute changeset.valid?
    end
  end
end
