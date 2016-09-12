defmodule Ex338.FantasyLeagueTest do
  @moduledoc false

  use Ex338.ModelCase, async: true

  alias Ex338.FantasyLeague

  @valid_attrs %{fantasy_league_name: "2016 Div A", division: "A", year: 2016}
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
