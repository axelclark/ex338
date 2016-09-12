defmodule Ex338.TradeLineItemTest do
  use Ex338.ModelCase, aysnc: true

  alias Ex338.TradeLineItem

  @valid_attrs %{action: "some content", trade_id: 1, fantasy_team_id: 12,
                 fantasy_player_id: 5}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = TradeLineItem.changeset(%TradeLineItem{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = TradeLineItem.changeset(%TradeLineItem{}, @invalid_attrs)
    refute changeset.valid?
  end
end
