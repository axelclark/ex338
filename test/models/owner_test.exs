defmodule Ex338.OwnerTest do
  use Ex338.ModelCase, async: true

  alias Ex338.Owner

  @valid_attrs %{fantasy_team_id: 1, user_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Owner.changeset(%Owner{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Owner.changeset(%Owner{}, @invalid_attrs)
    refute changeset.valid?
  end
end
