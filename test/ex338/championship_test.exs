defmodule Ex338.ChampionshipTest do
  use Ex338.DataCase

  alias Ex338.{Championship, CalendarAssistant}

  describe "add_deadline_statuses/1" do
    test "add boolean with status of deadlines" do
      team = %Championship{
        championship_at: CalendarAssistant.days_from_now(9),
        waiver_deadline_at: CalendarAssistant.days_from_now(-9),
        trade_deadline_at: CalendarAssistant.days_from_now(-9)
      }

      championship = Championship.add_deadline_statuses(team)

      assert championship.season_ended? == false
      assert championship.waivers_closed? == true
      assert championship.trades_closed? == true
    end
  end

  describe "changeset/2" do
    @valid_attrs %{
      category: "overall",
      championship_at: CalendarAssistant.days_from_now(100),
      title: "some content",
      trade_deadline_at: CalendarAssistant.days_from_now(15),
      waiver_deadline_at: CalendarAssistant.days_from_now(15),
      sports_league_id: 1,
      year: 2017
    }
    test "with valid attributes" do
      changeset = Championship.changeset(%Championship{}, @valid_attrs)
      assert changeset.valid?
    end

    @invalid_attrs %{}
    test "with invalid attributes" do
      changeset = Championship.changeset(%Championship{}, @invalid_attrs)
      refute changeset.valid?
    end

    @invalid_attrs %{
      category: "Overall",
      championship_at: CalendarAssistant.days_from_now(100),
      title: "some content",
      trade_deadline_at: CalendarAssistant.days_from_now(15),
      waiver_deadline_at: CalendarAssistant.days_from_now(15),
      sports_league_id: 1,
      year: 2017
    }
    test "error with invalid category" do
      changeset = Championship.changeset(%Championship{}, @invalid_attrs)
      refute changeset.valid?
    end
  end
end
