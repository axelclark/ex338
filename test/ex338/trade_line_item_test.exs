defmodule Ex338.TradeLineItemTest do
  use Ex338.DataCase, aysnc: true

  alias Ex338.TradeLineItem

  @valid_attrs %{gaining_team_id: 12, fantasy_player_id: 5,
                 losing_team_id: 3}
  @invalid_attrs %{}
  describe "assoc_changeset/2" do
    test "changeset with valid attributes" do
      changeset = TradeLineItem.assoc_changeset(%TradeLineItem{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = TradeLineItem.assoc_changeset(%TradeLineItem{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  @valid_attrs %{trade_id: 1, gaining_team_id: 12, fantasy_player_id: 5,
                 losing_team_id: 3}
  @invalid_attrs %{gaining_team_id: 12, fantasy_player_id: 5,
                 losing_team_id: 3}
  describe "changeset/2" do
    test "changeset with valid attributes" do
      changeset = TradeLineItem.changeset(%TradeLineItem{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = TradeLineItem.changeset(%TradeLineItem{}, @invalid_attrs)
      refute changeset.valid?
    end
  end
end
