defmodule Ex338.ChampionshipSlot.SetSlotTest do
  use Ex338.ModelCase
  alias Ex338.ChampionshipSlot.SetSlot

  describe "update_team_slots/1" do
    test "calculates the slot for a champioship based on roster position" do
      team =
        %{roster_positions: [
          %{status: "active", position: "Flex1"},
          %{status: "active", position: "Flex2"},
          %{status: "active", position: "MTn"}
        ]}

      result = SetSlot.update_team_slots(team)

      assert result ==
        %{roster_positions: [
          %{status: "active", position: "MTn", slot: 1},
          %{status: "active", position: "Flex1", slot: 2},
          %{status: "active", position: "Flex2", slot: 3}
        ]}
    end
  end
end
