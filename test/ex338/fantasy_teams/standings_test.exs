defmodule Ex338.FantasyTeams.StandingsTest do
  use Ex338.DataCase, async: true

  alias Ex338.FantasyTeams.Standings

  describe "rank_points_winnings_for_teams/1" do
    test "calculates points/winnings for teams & adds to FantasyTeam struct" do
      teams = [
        %{
          team: "A",
          winnings_adj: 0,
          roster_positions: [
            %{fantasy_player: %{championship_results: []}},
            %{fantasy_player: %{championship_results: []}},
            %{fantasy_player: %{championship_results: []}}
          ],
          champ_with_events_results: []
        },
        %{
          team: "B",
          winnings_adj: 100,
          roster_positions: [
            %{fantasy_player: %{championship_results: [%{rank: 1, points: 8}]}},
            %{fantasy_player: %{championship_results: []}},
            %{fantasy_player: %{championship_results: [%{rank: 2, points: 5}]}}
          ],
          champ_with_events_results: [%{rank: 1, points: 8.0, winnings: 25.00}]
        },
        %{
          team: "C",
          winnings_adj: 0,
          roster_positions: [
            %{fantasy_player: %{championship_results: []}},
            %{fantasy_player: %{championship_results: []}},
            %{fantasy_player: %{championship_results: [%{rank: 2, points: 5}]}}
          ],
          champ_with_events_results: []
        }
      ]

      result = Standings.rank_points_winnings_for_teams(teams)

      assert Enum.map(result, & &1.winnings) == [160, 10, 0]
      assert Enum.map(result, & &1.points) == [21, 5, 0]
      assert Enum.map(result, & &1.rank) == [1, 2, 3]
      assert Enum.map(result, & &1.team) == ["B", "C", "A"]
    end
  end

  describe "update_points_winnings/1" do
    test "calculates points/winnings and adds to FantasyTeam struct" do
      team = %{
        winnings_adj: 100,
        roster_positions: [
          %{fantasy_player: %{championship_results: [%{rank: 1, points: 8}]}},
          %{fantasy_player: %{championship_results: []}},
          %{fantasy_player: %{championship_results: [%{rank: 2, points: 5}]}}
        ],
        champ_with_events_results: [
          %{rank: 1, points: 8.0, winnings: 25.00},
          %{rank: 2, points: 5.0, winnings: 10.00}
        ]
      }

      result = Standings.update_points_winnings(team)

      assert result.winnings == 170
      assert result.points == 26
    end
  end
end
