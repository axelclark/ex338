defmodule Ex338Web.DraftPickHTMLTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338Web.DraftPickHTML

  describe "current_picks/2" do
    test "returns last picks if no picks remaining" do
      amount = 10
      draft_picks = for n <- 1..16, do: %{draft_position: n, fantasy_player_id: n}

      results = DraftPickHTML.current_picks(draft_picks, amount)

      assert Enum.map(results, & &1.draft_position) == Enum.to_list(12..16)
    end

    test "returns first picks if no picks completed" do
      amount = 5
      draft_picks = for n <- 1..16, do: %{draft_position: n, fantasy_player_id: nil}

      results = DraftPickHTML.current_picks(draft_picks, amount)

      assert Enum.map(results, & &1.draft_position) == Enum.to_list(1..5)
    end

    test "returns last 5 and next 5 picks when amount 10 is provided" do
      amount = 10
      completed_draft_picks = for n <- 1..8, do: %{draft_position: n, fantasy_player_id: n}
      remaining_draft_picks = for n <- 9..16, do: %{draft_position: n, fantasy_player_id: nil}

      draft_picks = completed_draft_picks ++ remaining_draft_picks

      results = DraftPickHTML.current_picks(draft_picks, amount)

      assert Enum.map(results, & &1.draft_position) == Enum.to_list(4..13)
    end
  end
end
