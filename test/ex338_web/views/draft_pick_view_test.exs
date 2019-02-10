defmodule Ex338Web.DraftPickViewTest do
  use Ex338Web.ConnCase, async: true
  alias Ex338Web.{DraftPickView}

  describe "next_pick?/2" do
    test "returns true if the pick is next" do
      completed_pick = %{draft_position: 1, fantasy_player_id: 1}
      next_pick = %{draft_position: 2, fantasy_player_id: nil}
      draft_picks = [completed_pick, next_pick]

      assert DraftPickView.next_pick?(draft_picks, next_pick) == true
    end

    test "returns false if the pick has been made" do
      completed_pick = %{draft_position: 1, fantasy_player_id: 1}
      next_pick = %{draft_position: 2, fantasy_player_id: nil}
      draft_picks = [completed_pick, next_pick]

      assert DraftPickView.next_pick?(draft_picks, completed_pick) == false
    end

    test "returns false if the pick is later" do
      completed_pick = %{draft_position: 1, fantasy_player_id: 1}
      next_pick = %{draft_position: 2, fantasy_player_id: nil}
      future_pick = %{draft_position: 3, fantasy_player_id: nil}
      draft_picks = [completed_pick, next_pick, future_pick]

      assert DraftPickView.next_pick?(draft_picks, future_pick) == false
    end
  end

  describe "seconds_to_hours/1" do
    test "converts_seconds_to_hours" do
      assert DraftPickView.seconds_to_hours(0) == 0
      assert DraftPickView.seconds_to_hours(3600) == 1
      assert DraftPickView.seconds_to_hours(4200) == 1.16
    end
  end

  describe "seconds_to_mins/1" do
    test "converts_seconds_to_minutes" do
      assert DraftPickView.seconds_to_mins(0) == 0
      assert DraftPickView.seconds_to_mins(60) == 1
      assert DraftPickView.seconds_to_mins(70) == 1.16
    end
  end
end
