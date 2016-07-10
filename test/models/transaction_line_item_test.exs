defmodule Ex338.TransactionLineItemTest do
  use Ex338.ModelCase

  alias Ex338.TransactionLineItem

  @valid_attrs %{roster_transaction_id: 1, action: "some content",
                 fantasy_team_id: 12, fantasy_player_id: 5}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TransactionLineItem.changeset(%TransactionLineItem{}, 
                                              @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TransactionLineItem.changeset(%TransactionLineItem{}, 
                                              @invalid_attrs)
    refute changeset.valid?
  end
end
