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

  describe "order_by_amount/1" do
    test "orders winnings by amount" do
      a = insert(:historical_winning, amount: 100)
      b = insert(:historical_winning, amount: 300)
      c = insert(:historical_winning, amount: 200)

      result =
        HistoricalWinning
        |> HistoricalWinning.order_by_amount()
        |> Repo.all()

      assert Enum.map(result, & &1.id) == [b.id, c.id, a.id]
    end
  end
end
