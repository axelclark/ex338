defmodule Ex338.SportsLeagueTest do
  use Ex338.DataCase, async: true

  alias Ex338.SportsLeague

  @valid_attrs %{league_name: "some content", abbrev: "sc"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SportsLeague.changeset(%SportsLeague{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SportsLeague.changeset(%SportsLeague{}, @invalid_attrs)
    refute changeset.valid?
  end
end
