defmodule Ex338.FantasyTeamViewTest do
  use Ex338.ConnCase, async: true
  alias Ex338.{FantasyTeamView, RosterPosition}

  describe "sort_by_position/1" do
    test "returns struct sorted alphabetically by position" do
      positions = [%{position: "a"}, %{position: "c"}, %{position: "b"}]

      result = FantasyTeamView.sort_by_position(positions)

      assert Enum.map(result, &(&1.position)) == ["a", "b", "c"]
    end
  end

  describe "position_selections/1" do
    test "returns sports league abbrev and flex positions" do
      form_data = %{model: %{fantasy_player: %{sports_league: %{abbrev: "CBB"}}}}

      results = FantasyTeamView.position_selections(form_data)

      assert results == ["CBB"] ++ RosterPosition.flex_positions
    end
  end
end
