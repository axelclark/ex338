defmodule Ex338Web.DraftPickViewTest do
  use Ex338Web.ConnCase, async: true
  alias Ex338Web.{DraftPickView}
  alias Ex338.{FantasyTeam, DraftPick}

  describe "calculate_team_data/1" do
    test "returns summary of draft data" do
      team_a = %FantasyTeam{id: 1, team_name: "A"}
      team_b = %FantasyTeam{id: 2, team_name: "B"}
      team_c = %FantasyTeam{id: 3, team_name: "C"}

      draft_picks = [
        %DraftPick{
          draft_position: 1,
          fantasy_team_id: 1,
          fantasy_team: team_a,
          fantasy_player_id: 1,
          updated_at: ~N[2018-09-21 01:10:02.857392]
        },
        %DraftPick{
          draft_position: 2,
          fantasy_team_id: 2,
          fantasy_team: team_b,
          fantasy_player_id: 2,
          updated_at: ~N[2018-09-21 01:15:02.857392]
        },
        %DraftPick{
          draft_position: 3,
          fantasy_team_id: 1,
          fantasy_team: team_a,
          fantasy_player_id: 3,
          updated_at: ~N[2018-09-21 01:20:02.857392]
        },
        %DraftPick{
          draft_position: 4,
          fantasy_team_id: 2,
          fantasy_team: team_b,
          fantasy_player_id: 4,
          updated_at: ~N[2018-09-21 01:25:02.857392]
        },
        %DraftPick{
          draft_position: 5,
          fantasy_team_id: 1,
          fantasy_team: team_a,
          fantasy_player_id: nil,
          updated_at: ~N[2018-09-21 01:05:02.857392]
        },
        %DraftPick{
          draft_position: 6,
          fantasy_team_id: 3,
          fantasy_team: team_c,
          fantasy_player_id: nil,
          updated_at: ~N[2018-09-21 01:05:02.857392]
        }
      ]

      [c, a, b] = DraftPickView.calculate_team_data(draft_picks)

      assert a.id == 1
      assert b.id == 2
      assert c.id == 3
      assert a.team_name == "A"
      assert b.team_name == "B"
      assert c.team_name == "C"
      assert a.picks_selected == 2
      assert b.picks_selected == 2
      assert c.picks_selected == 0
      assert a.total_seconds_on_the_clock == 300
      assert b.total_seconds_on_the_clock == 600
      assert c.total_seconds_on_the_clock == 0
      assert a.avg_seconds_on_the_clock == 150
      assert b.avg_seconds_on_the_clock == 300
      assert c.avg_seconds_on_the_clock == 0
    end
  end

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
