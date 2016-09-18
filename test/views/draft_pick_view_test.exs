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

  describe "format_players_for_select/1" do
    test "returns name, abbrev, and id in a tuple" do
      players = [
        %{id: 124, league_abbrev: "CBB", player_name: "Notre Dame"},
        %{id: 127, league_abbrev: "CBB", player_name: "Ohio State "}
      ]

      result = DraftPickView.format_players_for_select(players)

      assert result == [{"Notre Dame, CBB", 124}, {"Ohio State , CBB", 127}]
    end
  end

  describe "sports_abbrevs/1" do
    test "returns list of unique sports abbrevs" do
      players = [
        %{id: 124, league_abbrev: "CBB", player_name: "Notre Dame"},
        %{id: 127, league_abbrev: "CBB", player_name: "Ohio State"},
        %{id: 128, league_abbrev: "CFB", player_name: "Ohio State"},
        %{id: 129, league_abbrev: "CHK", player_name: "Boston U"}
      ]

      result = DraftPickView.sports_abbrevs(players)

      assert result == ~w(CBB CFB CHK)
    end
  end
end
