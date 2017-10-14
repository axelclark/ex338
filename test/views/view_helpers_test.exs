defmodule Ex338Web.ViewHelpersViewTest do
  use Ex338Web.ConnCase, async: true
  alias Ex338.{FantasyTeam, User, InSeasonDraftPick, RosterPosition,
               Owner, DraftPick, Waiver, User}
  alias Ex338Web.{ViewHelpers}

  describe "admin_edit_path/1" do
    test "returns path to a resources admin edit page" do
      team = %FantasyTeam{id: 1}

      result = ViewHelpers.admin_edit_path(team)

      assert result == "/admin/fantasy_teams/1/edit"
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
      draft_pick =
        %DraftPick{
          fantasy_team: %FantasyTeam{
            owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
          }
        }

      assert ViewHelpers.owner?(current_user, draft_pick) == true
    end

    test "returns false for draft pick if user doesn't own the team" do
      current_user = %User{id: 3}
      draft_pick =
        %DraftPick{
          fantasy_team: %FantasyTeam{
            owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
          }
        }

      assert ViewHelpers.owner?(current_user, draft_pick) == false
    end

    test "returns true for in season draft pick if user owns the team" do
      current_user = %User{id: 1}
      draft_pick =
        %InSeasonDraftPick{
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
      draft_pick =
        %InSeasonDraftPick{
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
      draft_pick =
        %Waiver{
          fantasy_team: %FantasyTeam{
            owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
          }
        }

      assert ViewHelpers.owner?(current_user, draft_pick) == true
    end

    test "returns false for waiver if user doesn't own the team" do
      current_user = %User{id: 3}
      draft_pick =
        %Waiver{
          fantasy_team: %FantasyTeam{
            owners: [%Owner{user_id: 1}, %Owner{user_id: 2}]
          }
        }

      assert ViewHelpers.owner?(current_user, draft_pick) == false
    end
  end

  describe "format_players_for_select/1" do
    test "returns name, abbrev, and id in a tuple" do
      players = [
        %{id: 124, league_abbrev: "CBB", player_name: "Notre Dame"},
        %{id: 127, league_abbrev: "CBB", player_name: "Ohio State "}
      ]

      result = ViewHelpers.format_players_for_select(players)

      assert result == [{"Notre Dame, CBB", 124}, {"Ohio State , CBB", 127}]
    end
  end

  describe "sports_abbrevs/1" do
    test "returns list of unique sports abbrevs" do
      players = [
        %{id: 124, league_abbrev: "CBB", player_name: "Notre Dame"},
        %{id: 127, league_abbrev: "CBB", player_name: "Ohio State"},
        %{id: 128, league_abbrev: "CFB", player_name: "Ohio State"},
        %{id: 129, league_abbrev: "CHK", player_name: "Boston U"}
      ]

      result = ViewHelpers.sports_abbrevs(players)

      assert result == ~w(CBB CFB CHK)
    end
  end

  describe "short_date/1" do
    test "formats DateTime struct into short date" do
      date = Ecto.DateTime.cast!(
        %{day: 16, hour: 0, min: 0, month: 9, sec: 0, year: 2017})

      result = ViewHelpers.short_date(date)

      assert result == "Sep 16, 2017"
    end
  end

  describe "short_datetime_pst/1" do
    test "formats DateTime struct into short datetime in PST" do
      date = Ecto.DateTime.cast!(
        %{day: 16, hour: 22, min: 30, month: 9, sec: 0, year: 2017})

      result = ViewHelpers.short_datetime_pst(date)

      assert result == "Sep 16,  3:30 PM"
    end
  end
end
