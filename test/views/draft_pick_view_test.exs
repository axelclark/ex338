defmodule Ex338.DraftPickViewTest do
  use Ex338.ConnCase, async: true
  alias Ex338.{DraftPickView}

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

  describe "owner?/2" do
    test "returns true if user owns the team" do
      current_user = %{id: 1}
      draft_pick = %{fantasy_team: %{owners: [%{user_id: 1}, %{user_id: 2}]}}

      assert DraftPickView.owner?(current_user, draft_pick) == true
    end

    test "returns false if user doesn't own the team" do
      current_user = %{id: 3}
      draft_pick = %{fantasy_team: %{owners: [%{user_id: 1}, %{user_id: 2}]}}

      assert DraftPickView.owner?(current_user, draft_pick) == false
    end
  end
end
