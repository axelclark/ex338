defmodule Ex338.FantasyLeagues.LeagueSportTest do
  use Ex338.DataCase

  alias Ex338.FantasyLeagues.LeagueSport

  @valid_attrs %{fantasy_league_id: 1, sports_league_id: 2}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = LeagueSport.changeset(%LeagueSport{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = LeagueSport.changeset(%LeagueSport{}, @invalid_attrs)
    refute changeset.valid?
  end
end
