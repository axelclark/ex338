defmodule Ex338Web.ViewHelpersViewTest do
  use Ex338Web.ConnCase, async: true

  alias Ex338.{
    FantasyTeam,
    User,
    InSeasonDraftPick,
    RosterPositions.RosterPosition,
    Owner,
    DraftPick,
    Waivers.Waiver,
    SportsLeague,
    FantasyPlayer,
    User
  }

  alias Ex338Web.{ViewHelpers}

  describe "admin_edit_path/1" do
    test "returns path to a resources admin edit page" do
      team = %FantasyTeam{id: 1}

      result = ViewHelpers.admin_edit_path(team)

      assert result == "/admin/fantasy_teams/1/edit"
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

      assert ViewHelpers.display_future_pick(future_pick) ==
               "Axel's round 1 pick in next year's draft"
    end
  end

  describe "fantasy_team_link/2" do
    test "returns a link to fantasty team page from team name" do
      team = %FantasyTeam{id: 1, team_name: "Brown"}

      result = ViewHelpers.fantasy_team_link(build_conn(), team)

      assert result ==
               {:safe,
                [
                  60,
                  "a",
                  [[32, "href", 61, 34, "/fantasy_teams/1", 34]],
                  62,
                  "Brown",
                  60,
                  47,
                  "a",
                  62
                ]}
    end
  end

  describe "format_whole_dollars/1" do
    test "returns formats as currency" do
      assert ViewHelpers.format_whole_dollars(1000) == "$1,000"
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

      result = ViewHelpers.format_players_for_select(players)

      assert result == [
               [key: "Notre Dame, CBB", value: 124],
               [key: "Ohio State, CBB", value: 127]
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

      result = ViewHelpers.format_players_for_select(players)

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

      result = ViewHelpers.format_teams_for_select(teams)

      assert result == [
               [key: "Brown", value: 124, class: "fantasy-team-124"],
               [key: "Axel", value: 127, class: "fantasy-team-127"]
             ]
    end
  end

  describe "owner?/2" do
    test "returns true if user is the owner of a team" do
      owners = %FantasyTeam{owners: [%{user_id: 1}, %{user_id: 2}]}
      user = %User{id: 1}

      assert ViewHelpers.owner?(user, owners)
    end

    test "returns false if user is not the owner of a team" do
      owners = %FantasyTeam{owners: [%{user_id: 1}, %{user_id: 2}]}
      user = %User{id: 3}

      refute ViewHelpers.owner?(user, owners)
    end

    test "returns true for draft pick if user owns the team" do
      current_user = %User{id: 1}

      draft_pick = %DraftPick{
        fantasy_team: %FantasyTeam{
          owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
        }
      }

      assert ViewHelpers.owner?(current_user, draft_pick) == true
    end

    test "returns false for draft pick if user doesn't own the team" do
      current_user = %User{id: 3}

      draft_pick = %DraftPick{
        fantasy_team: %FantasyTeam{
          owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
        }
      }

      assert ViewHelpers.owner?(current_user, draft_pick) == false
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

      assert ViewHelpers.owner?(current_user, draft_pick) == true
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

      assert ViewHelpers.owner?(current_user, draft_pick) == false
    end

    test "returns true for waiver if user owns the team" do
      current_user = %User{id: 1}

      draft_pick = %Waiver{
        fantasy_team: %FantasyTeam{
          owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
        }
      }

      assert ViewHelpers.owner?(current_user, draft_pick) == true
    end

    test "returns false for waiver if user doesn't own the team" do
      current_user = %User{id: 3}

      draft_pick = %Waiver{
        fantasy_team: %FantasyTeam{
          owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
        }
      }

      assert ViewHelpers.owner?(current_user, draft_pick) == false
    end
  end

  describe "short_date_pst/1" do
    test "formats DateTime struct into short date" do
      date = DateTime.from_naive!(~N[2017-09-16 22:30:00.000], "Etc/UTC")

      result = ViewHelpers.short_date_pst(date)

      assert result == "Sep 16, 2017"
    end

    test "formats Naive DateTime struct into short date" do
      date = ~N[2017-09-16 22:30:00.000]

      result = ViewHelpers.short_date_pst(date)

      assert result == "Sep 16, 2017"
    end
  end

  describe "short_datetime_pst/1" do
    test "formats DateTime struct into short datetime in PST" do
      date = DateTime.from_naive!(~N[2017-09-16 22:30:00.000], "Etc/UTC")

      result = ViewHelpers.short_datetime_pst(date)

      assert result == "Sep 16,  3:30 PM"
    end

    test "formats Naive DateTime struct into short datetime in PST" do
      date = ~N[2017-09-16 22:30:00.000]

      result = ViewHelpers.short_datetime_pst(date)

      assert result == "Sep 16,  3:30 PM"
    end
  end

  describe "sports_abbrevs/1" do
    test "returns list of unique sports abbrevs" do
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
        },
        %FantasyPlayer{
          id: 128,
          player_name: "Ohio State",
          sports_league: %SportsLeague{abbrev: "CFB"}
        },
        %FantasyPlayer{
          id: 129,
          player_name: "Boston U",
          sports_league: %SportsLeague{abbrev: "CHK"}
        }
      ]

      result = ViewHelpers.sports_abbrevs(players)

      assert result == ~w(CBB CFB CHK)
    end
  end
end
