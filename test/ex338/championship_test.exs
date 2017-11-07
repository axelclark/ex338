defmodule Ex338.ChampionshipTest do
  use Ex338.DataCase

  alias Ex338.{Championship, CalendarAssistant}

  @valid_attrs %{
    category: "some content",
    championship_at: CalendarAssistant.days_from_now(100),
    title: "some content",
    trade_deadline_at: CalendarAssistant.days_from_now(15),
    waiver_deadline_at: CalendarAssistant.days_from_now(15),
    sports_league_id: 1,
    year: 2017
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
