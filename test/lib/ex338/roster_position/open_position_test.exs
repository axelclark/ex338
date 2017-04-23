defmodule Ex338.RosterPosition.OpenPositionTest do
  use Ex338.ModelCase
  alias Ex338.{RosterPosition.OpenPosition, RosterPosition}

  describe "add_open_positions_to_teams/1" do
    test "adds position for any position without a player in a collection" do
      league_positions = RosterPosition.all_positions_for_2017()

      team_a =
        %{roster_positions: [%{position: "Unassigned", fantasy_player: %{}}]}
      team_b = %{roster_positions: [%{position: "CFB", fantasy_player: %{}}]}
      teams = [team_a, team_b]

      [a, b] = OpenPosition.add_open_positions_to_teams(teams, league_positions)

      assert Enum.count(a.roster_positions) == 21
      assert Enum.count(b.roster_positions) == 20
    end
  end

  describe "add_open_positions_to_team/1" do
    test "adds position for any position without a player for a team" do
      league_positions = RosterPosition.all_positions_for_2017()

      team_a =
        %{roster_positions: [
          %{position: "Unassigned", fantasy_player: %{}},
          %{position: "Unassigned", fantasy_player: %{}},
          %{position: "CFB", fantasy_player: %{}}
        ]}

      result = OpenPosition.add_open_positions_to_team(team_a, league_positions)

      assert Enum.count(result.roster_positions) == 22
    end
  end
end
