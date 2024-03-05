defmodule Ex338Web.HTMLHelpersViewTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338.Accounts.User
  alias Ex338.DraftPicks.DraftPick
  alias Ex338.FantasyPlayers.FantasyPlayer
  alias Ex338.FantasyPlayers.SportsLeague
  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.FantasyTeams.Owner
  alias Ex338.InSeasonDraftPicks.InSeasonDraftPick
  alias Ex338.RosterPositions.RosterPosition
  alias Ex338.Waivers.Waiver
  alias Ex338Web.HTMLHelpers

  describe "admin?/1" do
    test "returns false if no user" do
      current_user = nil

      result = HTMLHelpers.admin?(current_user)

      assert result == false
    end

    test "returns false if user is not admin" do
      current_user = %User{admin: false}

      result = HTMLHelpers.admin?(current_user)

      assert result == false
    end

    test "returns true if user is admin" do
      current_user = %User{admin: true}

      result = HTMLHelpers.admin?(current_user)

      assert result == true
    end
  end

  describe "display_future_pick/1" do
    test "returns future pick round with team" do
      future_pick = %{
        round: 1,
        original_team: %{
          team_name: "Axel"
        },
        current_team: %{
          team_name: "Brown"
        }
      }

      assert HTMLHelpers.display_future_pick(future_pick) ==
               "Axel's round 1 pick in next year's draft"
    end
  end

  describe "fantasy_team_link/2" do
    test "returns a link to fantasty team page from team name" do
      team = %FantasyTeam{id: 1, team_name: "Brown"}

      result = HTMLHelpers.fantasy_team_link(build_conn(), team)

      assert result ==
               {
                 :safe,
                 [
                   60,
                   "a",
                   [32, "href", 61, 34, "/fantasy_teams/1", 34],
                   62,
                   "Brown",
                   60,
                   47,
                   "a",
                   62
                 ]
               }
    end
  end

  describe "format_whole_dollars/1" do
    test "returns formats as currency" do
      assert HTMLHelpers.format_whole_dollars(1000) == "$1,000"
    end
  end

  describe "format_players_for_select/1" do
    test "returns name, abbrev, and id in a keyword list" do
      players = [
        %FantasyPlayer{
          id: 124,
          player_name: "Notre Dame",
          sports_league: %SportsLeague{abbrev: "CBB"}
        },
        %FantasyPlayer{
          id: 127,
          player_name: "Ohio State",
          sports_league: %SportsLeague{abbrev: "CBB"}
        }
      ]

      result = HTMLHelpers.format_players_for_select(players)

      assert result == [
               [key: "Notre Dame, CBB", value: 124, class: "CBB"],
               [key: "Ohio State, CBB", value: 127, class: "CBB"]
             ]
    end

    test "returns name, abbrev, id, fantasy team id in a keyword list" do
      players = [
        %{
          id: 124,
          league_abbrev: "CBB",
          player_name: "Notre Dame",
          fantasy_team_id: 1
        },
        %{
          id: 127,
          league_abbrev: "CBB",
          player_name: "Ohio State",
          fantasy_team_id: 2
        }
      ]

      result = HTMLHelpers.format_players_for_select(players)

      assert result == [
               [key: "Notre Dame, CBB", value: 124, class: "fantasy-team-1"],
               [key: "Ohio State, CBB", value: 127, class: "fantasy-team-2"]
             ]
    end
  end

  describe "format_teams_for_select/1" do
    test "returns name, abbrev, and id in a keyword list" do
      teams = [
        %{id: 124, team_name: "Brown"},
        %{id: 127, team_name: "Axel"}
      ]

      result = HTMLHelpers.format_teams_for_select(teams)

      assert result == [
               [key: "Brown", value: 124, class: "fantasy-team-124"],
               [key: "Axel", value: 127, class: "fantasy-team-127"]
             ]
    end
  end

  describe "maybe_fetch_current_user_id/1" do
    test "returns nil if no user" do
      current_user = nil

      result = HTMLHelpers.maybe_fetch_current_user_id(current_user)

      assert result == nil
    end

    test "returns id if user exists" do
      current_user = %User{id: 1}

      result = HTMLHelpers.maybe_fetch_current_user_id(current_user)

      assert result == 1
    end
  end

  describe "owner?/2" do
    test "returns false if no user" do
      user = nil
      owners = %FantasyTeam{owners: [%{user_id: 1}, %{user_id: 2}]}

      refute HTMLHelpers.owner?(user, owners)
    end

    test "returns true if user is the owner of a team" do
      owners = %FantasyTeam{owners: [%{user_id: 1}, %{user_id: 2}]}
      user = %User{id: 1}

      assert HTMLHelpers.owner?(user, owners)
    end

    test "returns false if user is not the owner of a team" do
      owners = %FantasyTeam{owners: [%{user_id: 1}, %{user_id: 2}]}
      user = %User{id: 3}

      refute HTMLHelpers.owner?(user, owners)
    end

    test "returns true for draft pick if user owns the team" do
      current_user = %User{id: 1}

      draft_pick = %DraftPick{
        fantasy_team: %FantasyTeam{
          owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
        }
      }

      assert HTMLHelpers.owner?(current_user, draft_pick) == true
    end

    test "returns false for draft pick if user doesn't own the team" do
      current_user = %User{id: 3}

      draft_pick = %DraftPick{
        fantasy_team: %FantasyTeam{
          owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
        }
      }

      assert HTMLHelpers.owner?(current_user, draft_pick) == false
    end

    test "returns true for in season draft pick if user owns the team" do
      current_user = %User{id: 1}

      draft_pick = %InSeasonDraftPick{
        draft_pick_asset: %RosterPosition{
          fantasy_team: %FantasyTeam{
            owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
          }
        }
      }

      assert HTMLHelpers.owner?(current_user, draft_pick) == true
    end

    test "returns false for in season draft pick if user doesn't own the team" do
      current_user = %User{id: 3}

      draft_pick = %InSeasonDraftPick{
        draft_pick_asset: %RosterPosition{
          fantasy_team: %FantasyTeam{
            owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
          }
        }
      }

      assert HTMLHelpers.owner?(current_user, draft_pick) == false
    end

    test "returns true for waiver if user owns the team" do
      current_user = %User{id: 1}

      draft_pick = %Waiver{
        fantasy_team: %FantasyTeam{
          owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
        }
      }

      assert HTMLHelpers.owner?(current_user, draft_pick) == true
    end

    test "returns false for waiver if user doesn't own the team" do
      current_user = %User{id: 3}

      draft_pick = %Waiver{
        fantasy_team: %FantasyTeam{
          owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
        }
      }

      assert HTMLHelpers.owner?(current_user, draft_pick) == false
    end
  end

  describe "short_date_pst/1" do
    test "formats DateTime struct into short date" do
      date = DateTime.from_naive!(~N[2017-09-16 22:30:00.000], "Etc/UTC")

      result = HTMLHelpers.short_date_pst(date)

      assert result == "Sep 16, 2017"
    end

    test "formats Naive DateTime struct into short date" do
      date = ~N[2017-09-16 22:30:00.000]

      result = HTMLHelpers.short_date_pst(date)

      assert result == "Sep 16, 2017"
    end
  end

  describe "short_datetime_pst/1" do
    test "formats DateTime struct into short datetime in PST" do
      date = DateTime.from_naive!(~N[2017-09-16 22:30:00.000], "Etc/UTC")

      result = HTMLHelpers.short_datetime_pst(date)

      assert result == "Sep 16,  3:30 PM"
    end

    test "formats Naive DateTime struct into short datetime in PST" do
      date = ~N[2017-09-16 22:30:00.000]

      result = HTMLHelpers.short_datetime_pst(date)

      assert result == "Sep 16,  3:30 PM"
    end
  end

  describe "short_time_pst/1" do
    test "formats DateTime struct into short time in PST with space for tens digit" do
      date = DateTime.from_naive!(~N[2017-09-16 22:30:00.000], "Etc/UTC")

      result = HTMLHelpers.short_time_pst(date)

      assert result == " 3:30 PM"
    end

    test "formats Naive DateTime struct into short time in PST" do
      date = ~N[2017-09-16 22:30:00.000]

      result = HTMLHelpers.short_time_pst(date)

      assert result == " 3:30 PM"
    end
  end

  describe "short_time_secs_pst/1" do
    test "formats DateTime struct into short time secs in PST with space for tens digit" do
      date = DateTime.from_naive!(~N[2017-09-16 22:30:40.000], "Etc/UTC")

      result = HTMLHelpers.short_time_secs_pst(date)

      assert result == " 3:30:40 PM"
    end

    test "formats Naive DateTime struct into short time in PST" do
      date = ~N[2017-09-16 22:30:40.000]

      result = HTMLHelpers.short_time_secs_pst(date)

      assert result == " 3:30:40 PM"
    end
  end

  describe "sports_abbrevs/1" do
    test "returns list of unique sports abbrevs" do
      players = [
        %FantasyPlayer{
          id: 124,
          player_name: "Notre Dame",
          sports_league: %SportsLeague{league_name: "College Basketball", abbrev: "CBB"}
        },
        %FantasyPlayer{
          id: 127,
          player_name: "Ohio State",
          sports_league: %SportsLeague{league_name: "College Basketball", abbrev: "CBB"}
        },
        %FantasyPlayer{
          id: 128,
          player_name: "Ohio State",
          sports_league: %SportsLeague{league_name: "College Football", abbrev: "CFB"}
        },
        %FantasyPlayer{
          id: 129,
          player_name: "Boston U",
          sports_league: %SportsLeague{league_name: "College Hockey", abbrev: "CHK"}
        }
      ]

      result = HTMLHelpers.sports_abbrevs(players)

      assert result == [
               [key: "College Basketball", value: "CBB"],
               [key: "College Football", value: "CFB"],
               [key: "College Hockey", value: "CHK"]
             ]
    end
  end
end
