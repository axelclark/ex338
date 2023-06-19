defmodule Ex338.DraftPicks.ClockTest do
  use Ex338.DataCase, async: true

  alias Ex338.{
    FantasyLeagues.FantasyLeague,
    FantasyTeams.FantasyTeam,
    DraftPicks.DraftPick,
    DraftPicks.Clock
  }

  describe "calculate_team_data/1" do
    test "returns summary of draft data" do
      league = %FantasyLeague{max_draft_hours: 1}

      team_a = %FantasyTeam{id: 1, team_name: "A", fantasy_league: league}
      team_b = %FantasyTeam{id: 2, team_name: "B", fantasy_league: league}
      team_c = %FantasyTeam{id: 3, team_name: "C", fantasy_league: league}

      seconds_in_an_hr = 3600

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
          seconds_on_the_clock: 3500
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
          fantasy_team: team_a,
          fantasy_player_id: 4,
          seconds_on_the_clock: seconds_in_an_hr
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

      [c, b, a] = Clock.calculate_team_data(draft_picks)

      assert a.id == 1
      assert b.id == 2
      assert c.id == 3
      assert a.team_name == "A"
      assert b.team_name == "B"
      assert c.team_name == "C"
      assert a.picks_selected == 3
      assert b.picks_selected == 1
      assert c.picks_selected == 0
      assert a.total_seconds_on_the_clock == 3900
      assert b.total_seconds_on_the_clock == 3500
      assert c.total_seconds_on_the_clock == 0
      assert a.avg_seconds_on_the_clock == 1300
      assert b.avg_seconds_on_the_clock == 3500
      assert c.avg_seconds_on_the_clock == 0
      assert a.over_draft_time_limit? == true
      assert b.over_draft_time_limit? == false
      assert c.over_draft_time_limit? == false
    end

    test "allows unlimited time for draft when max is 0" do
      league = %FantasyLeague{max_draft_hours: 0}

      team_a = %FantasyTeam{id: 1, team_name: "A", fantasy_league: league}
      team_b = %FantasyTeam{id: 2, team_name: "B", fantasy_league: league}

      seconds_in_an_hr = 3600

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
          seconds_on_the_clock: seconds_in_an_hr
        }
      ]

      [a, b] = Clock.calculate_team_data(draft_picks)

      assert a.over_draft_time_limit? == false
      assert b.over_draft_time_limit? == false
    end

    test "adjusts total_seconds_on_the_clock from for team" do
      league = %FantasyLeague{max_draft_hours: 1}

      team_a = %FantasyTeam{
        id: 1,
        team_name: "A",
        fantasy_league: league,
        total_draft_mins_adj: -10
      }

      seconds_in_an_hr = 3600

      draft_picks = [
        %DraftPick{
          draft_position: 1,
          fantasy_team_id: 1,
          fantasy_team: team_a,
          fantasy_player_id: 1,
          seconds_on_the_clock: 0
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
          fantasy_team: team_a,
          fantasy_player_id: 4,
          seconds_on_the_clock: seconds_in_an_hr
        },
        %DraftPick{
          draft_position: 5,
          fantasy_team_id: 1,
          fantasy_team: team_a,
          fantasy_player_id: nil,
          seconds_on_the_clock: nil
        }
      ]

      [a] = Clock.calculate_team_data(draft_picks)

      assert a.picks_selected == 3
      assert a.total_seconds_on_the_clock == 3300
      assert a.avg_seconds_on_the_clock == 1100
      assert a.over_draft_time_limit? == false
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
      [one, two, three, four, on_the_clock, six] = Enum.map(results, & &1.seconds_on_the_clock)

      assert one == 0
      assert two == 300
      assert three == 300
      assert four == 300
      assert on_the_clock > 300
      assert six == nil
    end

    test "calculates and updates seconds on the clock when picks are skipped" do
      draft_picks = [
        %DraftPick{
          draft_position: 1,
          fantasy_player_id: 1,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:10:02.857392], "Etc/UTC")
        },
        %DraftPick{
          draft_position: 2,
          fantasy_player_id: 2,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:30:02.857392], "Etc/UTC")
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
          fantasy_player_id: 5,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:50:02.857392], "Etc/UTC")
        },
        %DraftPick{
          draft_position: 6,
          fantasy_player_id: nil,
          drafted_at: nil
        }
      ]

      results = Clock.update_seconds_on_the_clock(draft_picks)
      [one, two, three, four, five, on_the_clock] = Enum.map(results, & &1.seconds_on_the_clock)

      assert one == 0
      assert two == 1200
      assert three == 0
      assert four == 0
      assert five == 1200
      assert on_the_clock > 1200
    end

    test "calculates seconds on the clock when picks are skipped and haven't been made" do
      draft_picks = [
        %DraftPick{
          draft_position: 1,
          fantasy_player_id: 1,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:10:02.857392], "Etc/UTC")
        },
        %DraftPick{
          draft_position: 2,
          fantasy_player_id: nil,
          drafted_at: nil
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
      [one, on_the_clock, three, four, five, six] = Enum.map(results, & &1.seconds_on_the_clock)

      assert one == 0
      assert on_the_clock > 1200
      assert three == 0
      assert four == 0
      assert five == nil
      assert six == nil
    end
  end

  describe "update_teams_in_picks/2" do
    test "updates fantasy teams in the draft picks from fantasy team list" do
      league = %FantasyLeague{max_draft_hours: 1}

      team_a = %FantasyTeam{id: 1, team_name: "A", fantasy_league: league}
      team_b = %FantasyTeam{id: 2, team_name: "B", fantasy_league: league}
      team_c = %FantasyTeam{id: 3, team_name: "C", fantasy_league: league}

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
