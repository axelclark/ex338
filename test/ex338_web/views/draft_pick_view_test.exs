defmodule Ex338Web.DraftPickViewTest do
  use Ex338Web.ConnCase, async: true
  alias Ex338Web.{DraftPickView}

  describe "current_picks/2" do
    test "returns last picks if no picks remaining" do
      amount = 10
      draft_picks = for n <- 1..16, do: %{draft_position: n, fantasy_player_id: n}

      results = DraftPickView.current_picks(draft_picks, amount)

      assert Enum.map(results, & &1.draft_position) == Enum.to_list(12..16)
    end

    test "returns first picks if no picks completed" do
      amount = 5
      draft_picks = for n <- 1..16, do: %{draft_position: n, fantasy_player_id: nil}

      results = DraftPickView.current_picks(draft_picks, amount)

      assert Enum.map(results, & &1.draft_position) == Enum.to_list(1..5)
    end

    test "returns last 5 and next 5 picks when amount 10 is provided" do
      amount = 10
      completed_draft_picks = for n <- 1..8, do: %{draft_position: n, fantasy_player_id: n}
      remaining_draft_picks = for n <- 9..16, do: %{draft_position: n, fantasy_player_id: nil}

      draft_picks = completed_draft_picks ++ remaining_draft_picks

      results = DraftPickView.current_picks(draft_picks, amount)

      assert Enum.map(results, & &1.draft_position) == Enum.to_list(4..13)
    end
  end

  describe "available_to_pick?/2" do
    test "returns whether the pick is availble to make with skips" do
      team_a = %{over_draft_time_limit?: false}
      team_b = %{over_draft_time_limit?: true}
      team_c = %{over_draft_time_limit?: true}
      team_d = %{over_draft_time_limit?: false}

      completed_pick = %{draft_position: 1, fantasy_player_id: 1, fantasy_team: team_a}
      skipped_pick = %{draft_position: 2, fantasy_player_id: nil, fantasy_team: team_b}
      other_skipped_pick = %{draft_position: 3, fantasy_player_id: nil, fantasy_team: team_c}
      next_pick = %{draft_position: 4, fantasy_player_id: nil, fantasy_team: team_d}
      not_available = %{draft_position: 5, fantasy_player_id: nil, fantasy_team: team_a}

      draft_picks = [completed_pick, skipped_pick, other_skipped_pick, next_pick, not_available]

      assert DraftPickView.available_to_pick?(draft_picks, completed_pick) == false
      assert DraftPickView.available_to_pick?(draft_picks, skipped_pick) == true
      assert DraftPickView.available_to_pick?(draft_picks, other_skipped_pick) == true
      assert DraftPickView.available_to_pick?(draft_picks, next_pick) == true
      assert DraftPickView.available_to_pick?(draft_picks, not_available) == false
    end

    test "returns whether the pick is availble to make when next pick" do
      team_a = %{over_draft_time_limit?: false}
      team_b = %{over_draft_time_limit?: false}
      team_c = %{over_draft_time_limit?: false}

      completed_pick = %{draft_position: 1, fantasy_player_id: 1, fantasy_team: team_a}
      next_pick = %{draft_position: 2, fantasy_player_id: nil, fantasy_team: team_b}
      not_available = %{draft_position: 3, fantasy_player_id: nil, fantasy_team: team_c}

      draft_picks = [completed_pick, next_pick, not_available]

      assert DraftPickView.available_to_pick?(draft_picks, completed_pick) == false
      assert DraftPickView.available_to_pick?(draft_picks, next_pick) == true
      assert DraftPickView.available_to_pick?(draft_picks, not_available) == false
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
