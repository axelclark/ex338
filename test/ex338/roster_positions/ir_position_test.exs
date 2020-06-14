defmodule Ex338.RosterPositions.IRPositionTest do
  use Ex338.DataCase, async: true
  alias Ex338.RosterPositions.IRPosition

  describe "separate_from_active_for_teams/1" do
    test "puts all ir position under ir_positions key and renames position" do
      teams = [
        %{
          roster_positions: [
            %{status: "active"},
            %{status: "active"},
            %{status: "injured_reserve", position: "CFB"}
          ]
        },
        %{
          roster_positions: [
            %{status: "active"},
            %{status: "active"},
            %{status: "active"},
            %{status: "injured_reserve"}
          ]
        }
      ]

      result = IRPosition.separate_from_active_for_teams(teams)
      team_a = List.first(result)
      team_b = List.last(result)
      team_a_ir = List.first(team_a.ir_positions)

      assert Enum.count(team_a.roster_positions) == 2
      assert Enum.count(team_a.ir_positions) == 1
      assert team_a_ir.position == "Injured Reserve"
      assert Enum.count(team_b.roster_positions) == 3
      assert Enum.count(team_b.ir_positions) == 1
    end
  end

  describe "separate_from_active_for_team/1" do
    test "puts all ir position under ir_positions key and renames position" do
      team = %{
        roster_positions: [
          %{status: "active"},
          %{status: "active"},
          %{status: "injured_reserve", position: "CFB"}
        ]
      }

      result = IRPosition.separate_from_active_for_team(team)
      ir_position = List.first(result.ir_positions)

      assert Enum.count(result.roster_positions) == 2
      assert Enum.count(result.ir_positions) == 1
      assert ir_position.position == "Injured Reserve"
    end

    test "returns fantasy team if no roster positions in map" do
      team = %{name: "Brown"}

      result = IRPosition.separate_from_active_for_team(team)

      assert result.name == "Brown"
    end
  end
end
