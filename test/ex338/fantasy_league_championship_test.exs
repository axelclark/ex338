defmodule Ex338.FantasyLeagueChampionshipTest do
  use Ex338.DataCase

  alias Ex338.FantasyLeagueChampionship

  @valid_attrs %{fantasy_league_id: 1, championship_id: 2}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = FantasyLeagueChampionship.changeset(%FantasyLeagueChampionship{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = FantasyLeagueChampionship.changeset(%FantasyLeagueChampionship{}, @invalid_attrs)
    refute changeset.valid?
  end
end
