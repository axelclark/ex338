defmodule Ex338Web.FantasyTeamViewTest do
  use Ex338Web.ConnCase, async: true
  alias Ex338.{FantasyLeague}
  alias Ex338Web.{FantasyTeamView}

  describe "display_autodraft_setting" do
    test "capitalizes on & off" do
      assert FantasyTeamView.display_autodraft_setting(:on) == "On"
      assert FantasyTeamView.display_autodraft_setting(:off) == "Off"
    end

    test "converts signle to make a pick & pause" do
      assert FantasyTeamView.display_autodraft_setting(:single) == "Make Pick & Pause"
    end
  end

  describe "display_points/1" do
    test "returns pointsfor a position" do
      position = %{
        season_ended?: true,
        fantasy_player: %{championship_results: [%{rank: 1, points: 8}]}
      }

      assert FantasyTeamView.display_points(position) == 8
    end

    test "returns an empty string if season hasn't ended" do
      position = %{season_ended?: false, fantasy_player: %{championship_results: []}}

      assert FantasyTeamView.display_points(position) == ""
    end

    test "returns an empty string if season_ended? is missing" do
      position = %{fantasy_player: %{championship_results: []}}

      assert FantasyTeamView.display_points(position) == ""
    end

    test "returns a dash if no points and season has ended" do
      position = %{season_ended?: true, fantasy_player: %{championship_results: []}}

      assert FantasyTeamView.display_points(position) == "-"
    end
  end

  describe "order_range/1" do
    test "returns number of draft queues as a range" do
      team_form_struct = %{data: %{draft_queues: [%{id: 4}, %{id: 5}]}}

      results = FantasyTeamView.order_range(team_form_struct)

      assert results == [1, 2]
    end

    test "returns empty list if no draft queues" do
      team_form_struct = %{data: %{draft_queues: []}}

      results = FantasyTeamView.order_range(team_form_struct)

      assert results == []
    end
  end

  describe "position_selections/1" do
    test "returns sports league abbrev and flex positions" do
      pos_form_struct = %{data: %{fantasy_player: %{sports_league: %{abbrev: "CBB"}}}}

      league = %FantasyLeague{id: 1, max_flex_spots: 2}

      results = FantasyTeamView.position_selections(pos_form_struct, league)

      assert results == ["CBB", "Flex1", "Flex2"]
    end
  end

  describe "queue_status_options/0" do
    test "returns draft queue status options for owner" do
      result = FantasyTeamView.queue_status_options()

      assert result == ["pending", "cancelled"]
    end
  end

  describe "sort_by_position/1" do
    test "returns struct sorted alphabetically by position" do
      positions = [%{position: "a"}, %{position: "c"}, %{position: "b"}]

      result = FantasyTeamView.sort_by_position(positions)

      assert Enum.map(result, & &1.position) == ["a", "b", "c"]
    end
  end
end
