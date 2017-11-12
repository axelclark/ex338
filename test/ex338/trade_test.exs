defmodule Ex338.TradeTest do
  use Ex338.DataCase, async: true

  alias Ex338.Trade

  @valid_attrs %{}
  test "changeset requires no attributes and provides default status" do
    changeset = Trade.changeset(%Trade{}, @valid_attrs)
    assert changeset.valid?
    assert changeset.data.status == "Pending"
  end

  @invalid_attrs %{}
  test "changeset invalid without assoc to cast" do
    changeset = Trade.new_changeset(%Trade{}, @invalid_attrs)
    refute changeset.valid?
  end

  @valid_attrs %{trade_line_items:
   [
     %{gaining_team_id: 12, fantasy_player_id: 5, losing_team_id: 3}
   ]
  }
  test "changeset valide with assoc to cast" do
    changeset = Trade.new_changeset(%Trade{}, @valid_attrs)
    assert changeset.valid?
  end
end
