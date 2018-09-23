defmodule Ex338.DraftPickTest do
  use Ex338.DataCase, async: true

  alias Ex338.DraftPick

  @valid_attrs %{draft_position: "1.05", round: 42, fantasy_league_id: 1}
  @valid_user_attrs %{
    draft_position: "1.05",
    round: 42,
    fantasy_league_id: 1,
    fantasy_team_id: 1,
    fantasy_player_id: 1
  }
  @invalid_attrs %{}

  describe "changeset/2" do
    test "changeset with valid attributes" do
      changeset = DraftPick.changeset(%DraftPick{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with invalid attributes" do
      changeset = DraftPick.changeset(%DraftPick{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "owner_changeset/2" do
    test "owner_changeset with valid attributes" do
      changeset = DraftPick.owner_changeset(%DraftPick{}, @valid_user_attrs)
      assert changeset.valid?
    end

    test "owner_changeset only allows update to fantasy player" do
      changeset = DraftPick.owner_changeset(%DraftPick{}, @valid_user_attrs)
      assert changeset.changes == %{fantasy_player_id: 1}
    end

    test "owner_changeset with invalid attributes" do
      changeset = DraftPick.owner_changeset(%DraftPick{}, @valid_attrs)
      refute changeset.valid?
    end

    test "valid when under max flex slots" do
      league = insert(:fantasy_league, max_flex_spots: 5)
      team = insert(:fantasy_team, fantasy_league: league)
      regular_positions = insert_list(4, :roster_position, fantasy_team: team)

      flex_sport = List.first(regular_positions).fantasy_player.sports_league

      [add | plyrs] = insert_list(5, :fantasy_player, sports_league: flex_sport)

      _flex_slots =
        for plyr <- plyrs do
          insert(:roster_position, fantasy_team: team, fantasy_player: plyr)
        end

      draft_pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team)

      attrs = %{
        fantasy_player_id: add.id
      }

      changeset = DraftPick.owner_changeset(draft_pick, attrs)

      assert changeset.valid?
    end

    test "error if too many flex spots in use" do
      league = insert(:fantasy_league, max_flex_spots: 5)
      team = insert(:fantasy_team, fantasy_league: league)
      regular_positions = insert_list(4, :roster_position, fantasy_team: team)

      flex_sport = List.first(regular_positions).fantasy_player.sports_league

      [add | plyrs] = insert_list(7, :fantasy_player, sports_league: flex_sport)

      _flex_slots =
        for plyr <- plyrs do
          insert(:roster_position, fantasy_team: team, fantasy_player: plyr)
        end

      draft_pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team)

      attrs = %{
        fantasy_player_id: add.id
      }

      changeset = DraftPick.owner_changeset(draft_pick, attrs)

      refute changeset.valid?
    end

    test "error if available players equal to teams needing to fill league rosters" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      _team_b = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      draft_pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team_a)

      attrs = %{
        fantasy_player_id: player_b.id
      }

      changeset = DraftPick.owner_changeset(draft_pick, attrs)

      refute changeset.valid?
    end

    test "error if available players less than teams needing to fill league rosters" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      _team_b = insert(:fantasy_team, fantasy_league: league)
      _team_c = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      draft_pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team_a)

      attrs = %{
        fantasy_player_id: player_b.id
      }

      changeset = DraftPick.owner_changeset(draft_pick, attrs)

      refute changeset.valid?
    end

    test "valid if team needs player to fill sport position" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      draft_pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team_b)

      attrs = %{
        fantasy_player_id: player_b.id
      }

      changeset = DraftPick.owner_changeset(draft_pick, attrs)

      assert changeset.valid?
    end
  end
end
