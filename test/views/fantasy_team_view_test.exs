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

  describe "display_points/1" do
    test "returns pointsfor a position" do
      position = %{season_ended?: true, fantasy_player:
        %{championship_results: [%{rank: 1, points: 8}]}}

      assert FantasyTeamView.display_points(position) == 8
    end

    test "returns an empty string if season hasn't ended" do
      position = %{season_ended?: false, fantasy_player:
        %{championship_results: []}}

      assert FantasyTeamView.display_points(position) == ""
    end

    test "returns an empty string if season_ended? is missing" do
      position = %{fantasy_player:
        %{championship_results: []}}

      assert FantasyTeamView.display_points(position) == ""
    end

    test "returns a dash if no points and season has ended" do
      position = %{season_ended?: true, fantasy_player:
        %{championship_results: []}}

      assert FantasyTeamView.display_points(position) == "-"
    end
  end
end
