defmodule Ex338.FantasyTeam.StandingsTest do
  use Ex338.ModelCase
  alias Ex338.FantasyTeam.Standings

  describe "get_points_winnings_for_teams" do
    test "calculates points/winnings for teams & adds to FantasyTeam struct" do
      teams = [
        %{team: "A", roster_positions: [
          %{fantasy_player: %{championship_results: []}},
          %{fantasy_player: %{championship_results: []}},
          %{fantasy_player: %{championship_results: []}}
        ]},
        %{team: "B", roster_positions: [
          %{fantasy_player: %{championship_results: [%{rank: 1, points: 8}]}},
          %{fantasy_player: %{championship_results: []}},
          %{fantasy_player: %{championship_results: [%{rank: 2, points: 5}]}}
        ]},
        %{team: "C", roster_positions: [
          %{fantasy_player: %{championship_results: []}},
          %{fantasy_player: %{championship_results: []}},
          %{fantasy_player: %{championship_results: [%{rank: 2, points: 5}]}}
        ]}
      ]

      result = Standings.update_points_winnings_for_teams(teams)

      assert Enum.map(result, &(&1.winnings)) == [35, 10, 0]
      assert Enum.map(result, &(&1.points)) == [13, 5, 0]
      assert Enum.map(result, &(&1.rank)) == [1, 2, 3]
      assert Enum.map(result, &(&1.team)) == ["B", "C", "A"]
    end
  end

  describe "get_points_winnings" do
    test "calculates points/winnings and adds to FantasyTeam struct" do
      team =
        %{roster_positions: [
          %{fantasy_player: %{championship_results: [%{rank: 1, points: 8}]}},
          %{fantasy_player: %{championship_results: []}},
          %{fantasy_player: %{championship_results: [%{rank: 2, points: 5}]}}
        ]}

      result = Standings.update_points_winnings(team)

      assert result.winnings == 35
      assert result.points == 13
    end
  end
end
