defmodule Ex338.RosterPositionTest do
  use Ex338.ModelCase, async: true

  alias Ex338.RosterPosition

  @valid_attrs %{position: "some content", fantasy_team_id: 12}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RosterPosition.changeset(%RosterPosition{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RosterPosition.changeset(%RosterPosition{}, @invalid_attrs)
    refute changeset.valid?
  end
end
