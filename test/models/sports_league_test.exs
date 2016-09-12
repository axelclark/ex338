defmodule Ex338.SportsLeagueTest do
  use Ex338.ModelCase, async: true

  alias Ex338.SportsLeague

  @valid_attrs %{league_name: "some content", abbrev: "sc",
   championship_date: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010},
   trade_deadline: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010},
   waiver_deadline: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
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
