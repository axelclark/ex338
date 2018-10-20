defmodule Ex338Web.FantasyLeagueViewTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338Web.FantasyLeagueView

  describe "allow_vote?/2" do
    test "returns true if team can still vote" do
      standings_history = [
        %{points: [0, 0, 8, 8, 8, 8, 13, 13, 13, 13, 13, 13], team_name: "A"},
        %{points: [0, 0, 0, 0, 0, 0, 8, 8, 8, 8, 8, 8], team_name: "B"}
      ]

      [result_a, result_b] = FantasyLeagueView.format_dataset(standings_history)

      assert result_a.data == [0, 0, 8, 8, 8, 8, 13, 13, 13, 13, 13, 13]
      assert result_a.label == "A"
      assert result_a.borderColor == "#e6194B"
      assert result_b.data == [0, 0, 0, 0, 0, 0, 8, 8, 8, 8, 8, 8]
      assert result_b.label == "B"
      assert result_b.borderColor == "#3cb44b"
    end
  end
end
