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

  describe "display_deadline_icon/1" do
    test "returns an icon if all deadlines passed" do
      championship = %{waivers_closed?: true, trades_closed?: true}
      position = %{fantasy_player: %{sports_league: %{championships: [championship]}}}

      assert FantasyTeamView.deadline_icon_for_position(position) ==
               {:safe, ["" | "<ion-icon name=\"lock\"></ion-icon>\n"]}
    end

    test "returns an icon if waiver deadline passed" do
      championship = %{waivers_closed?: true, trades_closed?: false}
      position = %{fantasy_player: %{sports_league: %{championships: [championship]}}}

      assert FantasyTeamView.deadline_icon_for_position(position) ==
               {:safe, ["" | "<ion-icon name=\"swap\"></ion-icon>\n"]}
    end

    test "returns an empty string if no deadlines have passed" do
      championship = %{waivers_closed?: false, trades_closed?: false}
      position = %{fantasy_player: %{sports_league: %{championships: [championship]}}}

      assert FantasyTeamView.deadline_icon_for_position(position) == ""
    end
  end

  describe "display_points/1" do
    test "returns pointsfor a position" do
      position = %{
        fantasy_player: %{
          championship_results: [%{rank: 1, points: 8}],
          sports_league: %{
            championships: [
              %{season_ended?: true}
            ]
          }
        }
      }

      assert FantasyTeamView.display_points(position) == 8
    end

    test "returns an empty string if season hasn't ended" do
      position = %{
        fantasy_player: %{
          championship_results: [],
          sports_league: %{
            championships: [
              %{season_ended?: false}
            ]
          }
        }
      }

      assert FantasyTeamView.display_points(position) == ""
    end

    test "returns an empty string if season_ended? is missing" do
      position = %{
        fantasy_player: %{
          championship_results: [],
          sports_league: %{
            championships: []
          }
        }
      }

      assert FantasyTeamView.display_points(position) == ""
    end

    test "returns a zero if no points and season has ended" do
      position = %{
        fantasy_player: %{
          championship_results: [],
          sports_league: %{
            championships: [
              %{season_ended?: true}
            ]
          }
        }
      }

      assert FantasyTeamView.display_points(position) == 0
    end

    test "returns empty string if no fantasy player exists" do
      position = %{}

      assert FantasyTeamView.display_points(position) == ""
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
