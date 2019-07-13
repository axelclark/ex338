defmodule Ex338.DraftPick.ClockTest do
  use Ex338.DataCase, async: true

  alias Ex338.{FantasyTeam, DraftPick, DraftPick.Clock}

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
          seconds_on_the_clock: 0
        },
        %DraftPick{
          draft_position: 2,
          fantasy_team_id: 2,
          fantasy_team: team_b,
          fantasy_player_id: 2,
          seconds_on_the_clock: 300
        },
        %DraftPick{
          draft_position: 3,
          fantasy_team_id: 1,
          fantasy_team: team_a,
          fantasy_player_id: 3,
          seconds_on_the_clock: 300
        },
        %DraftPick{
          draft_position: 4,
          fantasy_team_id: 2,
          fantasy_team: team_b,
          fantasy_player_id: 4,
          seconds_on_the_clock: 300
        },
        %DraftPick{
          draft_position: 5,
          fantasy_team_id: 1,
          fantasy_team: team_a,
          fantasy_player_id: nil,
          seconds_on_the_clock: nil
        },
        %DraftPick{
          draft_position: 6,
          fantasy_team_id: 3,
          fantasy_team: team_c,
          fantasy_player_id: nil,
          seconds_on_the_clock: nil
        }
      ]

      [c, a, b] = Clock.calculate_team_data(draft_picks)

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

  describe "update_seconds_on_the_clock/1" do
    test "calculates and updates seconds on the clock for each pick" do
      draft_picks = [
        %DraftPick{
          draft_position: 1,
          fantasy_player_id: 1,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:10:02.857392], "Etc/UTC")
        },
        %DraftPick{
          draft_position: 2,
          fantasy_player_id: 2,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:15:02.857392], "Etc/UTC")
        },
        %DraftPick{
          draft_position: 3,
          fantasy_player_id: 3,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:20:02.857392], "Etc/UTC")
        },
        %DraftPick{
          draft_position: 4,
          fantasy_player_id: 4,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:25:02.857392], "Etc/UTC")
        },
        %DraftPick{
          draft_position: 5,
          fantasy_player_id: nil,
          drafted_at: nil
        },
        %DraftPick{
          draft_position: 6,
          fantasy_player_id: nil,
          drafted_at: nil
        }
      ]

      results = Clock.update_seconds_on_the_clock(draft_picks)

      assert Enum.map(results, & &1.seconds_on_the_clock) == [0, 300, 300, 300, nil, nil]
    end
  end

  describe "update_teams_in_picks/2" do
    test "updates fantasy teams in the draft picks from fantasy team list" do
      team_a = %FantasyTeam{id: 1, team_name: "A"}
      team_b = %FantasyTeam{id: 2, team_name: "B"}
      team_c = %FantasyTeam{id: 3, team_name: "C"}

      draft_picks = [
        %DraftPick{
          draft_position: 1,
          fantasy_team_id: 1,
          fantasy_team: team_a,
          fantasy_player_id: 1,
          seconds_on_the_clock: 0
        },
        %DraftPick{
          draft_position: 2,
          fantasy_team_id: 2,
          fantasy_team: team_b,
          fantasy_player_id: 2,
          seconds_on_the_clock: 300
        },
        %DraftPick{
          draft_position: 3,
          fantasy_team_id: 1,
          fantasy_team: team_a,
          fantasy_player_id: 3,
          seconds_on_the_clock: 300
        },
        %DraftPick{
          draft_position: 4,
          fantasy_team_id: 2,
          fantasy_team: team_b,
          fantasy_player_id: 4,
          seconds_on_the_clock: 300
        },
        %DraftPick{
          draft_position: 5,
          fantasy_team_id: 1,
          fantasy_team: team_a,
          fantasy_player_id: nil,
          seconds_on_the_clock: nil
        },
        %DraftPick{
          draft_position: 6,
          fantasy_team_id: 3,
          fantasy_team: team_c,
          fantasy_player_id: nil,
          seconds_on_the_clock: nil
        }
      ]

      updated_teams = Clock.calculate_team_data(draft_picks)

      [pick_one | _rest] = Clock.update_teams_in_picks(draft_picks, updated_teams)

      assert pick_one.fantasy_team.picks_selected == 2
      assert pick_one.fantasy_team.total_seconds_on_the_clock == 300
      assert pick_one.fantasy_team.avg_seconds_on_the_clock == 150
    end
  end
end
