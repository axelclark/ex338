defmodule Ex338.ValidateHelpersTest do
  use Ex338.DataCase, async: true

  alias Ex338.ValidateHelpers

  describe "slot_available/2" do
    test "returns false if too many flex spots in use" do
      max_flex_slots = 3
      tm = insert(:fantasy_team)
      regular_slots = insert_list(4, :roster_position, fantasy_team: tm)

      flex_sport = List.first(regular_slots).fantasy_player.sports_league

      plyrs = insert_list(4, :fantasy_player, sports_league: flex_sport)

      flex_slots =
        for plyr <- plyrs do
          build(:roster_position, fantasy_team: tm, fantasy_player: plyr)
        end

      all_slots = regular_slots ++ flex_slots

      result = ValidateHelpers.slot_available?(all_slots, max_flex_slots)

      assert result == false
    end

    test "returns true if flex slot is available" do
      max_flex_slots = 3
      tm = insert(:fantasy_team)
      regular_slots = insert_list(4, :roster_position, fantasy_team: tm)

      flex_sport = List.first(regular_slots).fantasy_player.sports_league

      plyrs = insert_list(3, :fantasy_player, sports_league: flex_sport)

      flex_slots =
        for plyr <- plyrs do
          build(:roster_position, fantasy_team: tm, fantasy_player: plyr)
        end

      all_slots = regular_slots ++ flex_slots

      result = ValidateHelpers.slot_available?(all_slots, max_flex_slots)

      assert result == true
    end
  end
end
