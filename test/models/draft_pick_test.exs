defmodule Ex338.DraftPickTest do
  use Ex338.ModelCase

  alias Ex338.DraftPick

  @valid_attrs %{draft_position: "1.05", round: 42, fantasy_league_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DraftPick.changeset(%DraftPick{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DraftPick.changeset(%DraftPick{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "convert_position_to_round/1" do
    test "converts all draft positions down to round" do
      assert DraftPick.convert_position_to_round(1.01) == 1
      assert DraftPick.convert_position_to_round(1.99) == 1
      assert DraftPick.convert_position_to_round(1.5) == 1
    end
  end
end
