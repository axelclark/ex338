defmodule Ex338.FantasyLeagueTest do
  use Ex338.ModelCase

  alias Ex338.FantasyLeague

  @valid_attrs %{division: "some content", year: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = FantasyLeague.changeset(%FantasyLeague{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = FantasyLeague.changeset(%FantasyLeague{}, @invalid_attrs)
    refute changeset.valid?
  end
end
