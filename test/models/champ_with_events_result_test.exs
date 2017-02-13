defmodule Ex338.ChampWithEventsResultTest do
  use Ex338.ModelCase

  alias Ex338.ChampWithEventsResult

  @valid_attrs %{points: "120.5", rank: 42, winnings: "120.5",
                 fantasy_team_id: 1, championship_id: 1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = ChampWithEventsResult.changeset(%ChampWithEventsResult{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = ChampWithEventsResult.changeset(%ChampWithEventsResult{}, @invalid_attrs)
    refute changeset.valid?
  end
end
