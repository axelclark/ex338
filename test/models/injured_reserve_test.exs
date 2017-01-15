defmodule Ex338.InjuredReserveTest do
  use Ex338.ModelCase

  alias Ex338.InjuredReserve

  @valid_attrs %{fantasy_team_id: 1, status: "pending"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = InjuredReserve.changeset(%InjuredReserve{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = InjuredReserve.changeset(%InjuredReserve{}, @invalid_attrs)
    refute changeset.valid?
  end
end
