defmodule Ex338.FantasyTeams.StandingsHistoryTest do
  use Ex338.DataCase, async: true

  alias Ex338.FantasyTeams.StandingsHistory

  describe "get_dates_for_league/1" do
    test "returns list of dates with 1st of the month for a league" do
      league = %{year: 2018}
      {:ok, expected_datetime, _} = DateTime.from_iso8601("2018-01-01T00:00:00Z")

      result = StandingsHistory.get_dates_for_league(league)

      assert List.first(result) == expected_datetime
      assert Enum.map(result, & &1.month) == Enum.map(1..12, & &1)
    end
  end

  describe "group_by_team/1" do
    test "returns list teams with points formatted" do
      standings_by_month = [
        [
          %{team_name: "A", points: 0},
          %{team_name: "B", points: 0}
        ],
        [
          %{team_name: "A", points: 5},
          %{team_name: "B", points: 0}
        ],
        [
          %{team_name: "A", points: 10},
          %{team_name: "B", points: 5}
        ]
      ]

      results = StandingsHistory.group_by_team(standings_by_month)

      assert results == [
               %{team_name: "A", points: [0, 5, 10]},
               %{team_name: "B", points: [0, 0, 5]}
             ]
    end
  end
end
