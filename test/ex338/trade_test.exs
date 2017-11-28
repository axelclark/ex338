defmodule Ex338.TradeTest do
  use Ex338.DataCase, async: true

  alias Ex338.Trade

  describe "changeset/2" do
    @valid_attrs %{}
    test "changeset requires no attributes and provides default status" do
      changeset = Trade.changeset(%Trade{}, @valid_attrs)
      assert changeset.valid?
      assert changeset.data.status == "Pending"
    end

    @invalid_attrs %{status: "pending"}
    test "changeset invalid when incorrect status option provided" do
      changeset = Trade.changeset(%Trade{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "new_changeset/2" do
    @valid_attrs %{trade_line_items:
     [
       %{gaining_team_id: 12, fantasy_player_id: 5, losing_team_id: 3}
     ]
   }
   test "valid with assoc to cast" do
     changeset = Trade.new_changeset(%Trade{}, @valid_attrs)
     assert changeset.valid?
   end

   @invalid_attrs %{}
   test "invalid without assoc to cast" do
     changeset = Trade.new_changeset(%Trade{}, @invalid_attrs)
     refute changeset.valid?
   end

   @invalid_attrs %{status: "pending"}
   test "invalid when incorrect status option provided" do
     changeset = Trade.new_changeset(%Trade{}, @invalid_attrs)
     refute changeset.valid?
   end
  end
end
