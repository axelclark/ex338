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
      form_data = %{data: %{fantasy_player: %{sports_league: %{abbrev: "CBB"}}}}

      results = FantasyTeamView.position_selections(form_data)

      assert results == ["CBB"] ++ RosterPosition.flex_positions
    end
  end

  describe "display_results/2" do
    test "returns values under championship result keys" do
      position = %{fantasy_player: %{championship_results: [%{rank: 1, points: 8}]}}

      assert FantasyTeamView.display_results(position, :rank) == 1
      assert FantasyTeamView.display_results(position, :points) == 8
    end

    test "returns an empty string if no championship results" do
      position = %{fantasy_player: %{championship_results: []}}

      assert FantasyTeamView.display_results(position, :rank) == ""
      assert FantasyTeamView.display_results(position, :points) == ""
    end
  end
end
