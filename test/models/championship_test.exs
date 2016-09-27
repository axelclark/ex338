defmodule Ex338.ChampionshipTest do
  use Ex338.ModelCase

  alias Ex338.Championship

  @valid_attrs %{
    category: "some content",
    championship_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010},
    title: "some content",
    trade_deadline_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010},
    waiver_deadline_at: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010},
    sports_league_id: 1
  }
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Championship.changeset(%Championship{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Championship.changeset(%Championship{}, @invalid_attrs)
    refute changeset.valid?
  end
end
