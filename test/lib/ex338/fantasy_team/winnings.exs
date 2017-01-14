defmodule Ex338.FantasyTeam.WinningsTest do
  use Ex338.ModelCase
  alias Ex338.FantasyTeam.Winnings

  describe "get_winnings_for_teams" do
    test "calculates winnings for teams and adds to FantasyTeam struct" do
      teams = [
        %{roster_positions: [
          %{fantasy_player: %{championship_results: [%{rank: 1, points: 8}]}},
          %{fantasy_player: %{championship_results: []}},
          %{fantasy_player: %{championship_results: [%{rank: 2, points: 5}]}}
        ]},
        %{roster_positions: [
          %{fantasy_player: %{championship_results: []}},
          %{fantasy_player: %{championship_results: []}},
          %{fantasy_player: %{championship_results: [%{rank: 2, points: 5}]}}
        ]}
      ]

      result = Winnings.get_winnings_for_teams(teams)

      assert Enum.map(result, &(&1.winnings)) == [35, 10]
    end
  end

  describe "get_winnings" do
    test "calculates winnings and adds to FantasyTeam struct" do
      team =
        %{roster_positions: [
          %{fantasy_player: %{championship_results: [%{rank: 1, points: 8}]}},
          %{fantasy_player: %{championship_results: []}},
          %{fantasy_player: %{championship_results: [%{rank: 2, points: 5}]}}
        ]}

      result = Winnings.get_winnings(team)

      assert result.winnings == 35
    end
  end
end
