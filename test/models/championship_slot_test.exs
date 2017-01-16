defmodule Ex338.ChampionshipSlotTest do
  use Ex338.ModelCase

  alias Ex338.ChampionshipSlot

  @valid_attrs %{slot: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ChampionshipSlot.changeset(%ChampionshipSlot{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ChampionshipSlot.changeset(%ChampionshipSlot{}, @invalid_attrs)
    refute changeset.valid?
  end
end
