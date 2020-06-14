defmodule Ex338.InjuredReserves.InjuredReserveTest do
  use Ex338.DataCase, async: true

  alias Ex338.InjuredReserves.InjuredReserve

  describe "changeset/2" do
    @valid_attrs %{fantasy_team_id: 1, status: "pending"}
    test "with valid attributes" do
      changeset = InjuredReserve.changeset(%InjuredReserve{}, @valid_attrs)
      assert changeset.valid?
    end

    @invalid_attrs %{}
    test "with invalid attributes" do
      changeset = InjuredReserve.changeset(%InjuredReserve{}, @invalid_attrs)
      refute changeset.valid?
    end

    @invalid_attrs %{fantasy_team_id: 1, status: "Pending"}
    test "with invalid status" do
      changeset = InjuredReserve.changeset(%InjuredReserve{}, @invalid_attrs)
      refute changeset.valid?
    end
  end
end
