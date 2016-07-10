defmodule Ex338.RosterTransactionTest do
  use Ex338.ModelCase

  alias Ex338.RosterTransaction

  @valid_attrs %{category: "some content", 
                 roster_transaction_on: %{day: 17, hour: 14, min: 0, month: 4, 
                                          sec: 0, year: 2010}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RosterTransaction.changeset(%RosterTransaction{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RosterTransaction.changeset(%RosterTransaction{}, @invalid_attrs)
    refute changeset.valid?
  end
end
