defmodule Ex338.FantasyLeagueViewTest do
  use Ex338.ConnCase, async: true
  alias Ex338.{FantasyLeagueView}

  describe "sort_by_points/1" do
    test "sorts teams by the sum of their points" do
      team_a =
        %{roster_positions: [
          %{fantasy_player: %{championship_results: [%{rank: 1, points: 8}]}},
          %{fantasy_player: %{championship_results: [%{rank: 2, points: 5}]}}
        ], name: "A"}

      team_b =
        %{roster_positions: [
          %{fantasy_player: %{championship_results: [%{rank: 1, points: 0}]}},
          %{fantasy_player: %{championship_results: [%{rank: 2, points: 1}]}}
        ], name: "B"}

      teams = [team_b, team_a]

      sorted_teams = FantasyLeagueView.sort_by_points(teams)

      assert Enum.map(sorted_teams, &(&1.name)) == ~w(A B)
    end
  end
end
