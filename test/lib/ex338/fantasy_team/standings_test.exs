defmodule Ex338.FantasyTeam.StandingsTest do
  use Ex338.ModelCase
  alias Ex338.{FantasyTeam.Standings, CalendarAssistant}

  describe "get_points_winnings_for_teams/1" do
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

  describe "get_points_winnings/1" do
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

  describe "add_season_ended_for_league/1" do
    test "add boolean whether season has ended" do
      teams = [
        %{team: "A", roster_positions: [
          %{pos: "A",fantasy_player: %{sports_league: %{championships: [
            %{championship_at: CalendarAssistant.days_from_now(9)}
          ]}}},
          %{pos: "B", fantasy_player: %{sports_league: %{championships: [
            %{championship_at: CalendarAssistant.days_from_now(-9)}
          ]}}}
        ]},
        %{team: "A", roster_positions: [
          %{pos: "A",fantasy_player: %{sports_league: %{championships: [
            %{championship_at: CalendarAssistant.days_from_now(9)}
          ]}}},
          %{pos: "B", fantasy_player: %{sports_league: %{championships: [
            %{championship_at: CalendarAssistant.days_from_now(-9)}
          ]}}}
        ]}
      ]

       [team_a, _team_b] = Standings.add_season_ended_for_league(teams)
       %{roster_positions: [a, b]} = team_a

      assert a.season_ended? == false
      assert b.season_ended? == true

    end
  end

  describe "add_season_ended/1" do
    test "add boolean whether season has ended" do
      team =
        %{roster_positions: [
          %{pos: "A",fantasy_player: %{sports_league: %{championships: [
            %{championship_at: CalendarAssistant.days_from_now(9)}
          ]}}},
          %{pos: "B", fantasy_player: %{sports_league: %{championships: [
            %{championship_at: CalendarAssistant.days_from_now(-9)}
          ]}}}
        ]}

      %{roster_positions: [a, b]} = Standings.add_season_ended(team)

      assert a.season_ended? == false
      assert b.season_ended? == true

    end
  end
end
