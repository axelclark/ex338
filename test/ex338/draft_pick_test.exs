defmodule Ex338.DraftPickTest do
  use Ex338.DataCase, async: true

  alias Ex338.{CalendarAssistant, DraftPick}

  describe "available_with_skipped_picks?/2" do
    test "returns whether the pick is availble to make with skips" do
      team_a = %{over_draft_time_limit?: false}
      team_b = %{over_draft_time_limit?: true}
      team_c = %{over_draft_time_limit?: true}
      team_d = %{over_draft_time_limit?: false}

      completed_pick = %{id: 1, draft_position: 1, fantasy_player_id: 1, fantasy_team: team_a}
      skipped_pick = %{id: 2, draft_position: 2, fantasy_player_id: nil, fantasy_team: team_b}
      skipped_pick2 = %{id: 3, draft_position: 3, fantasy_player_id: nil, fantasy_team: team_c}
      next_pick = %{id: 4, draft_position: 4, fantasy_player_id: nil, fantasy_team: team_d}
      not_available = %{id: 5, draft_position: 5, fantasy_player_id: nil, fantasy_team: team_a}

      draft_picks = [completed_pick, skipped_pick, skipped_pick2, next_pick, not_available]

      assert DraftPick.available_with_skipped_picks?(completed_pick.id, draft_picks) == false
      assert DraftPick.available_with_skipped_picks?(skipped_pick.id, draft_picks) == true
      assert DraftPick.available_with_skipped_picks?(skipped_pick2.id, draft_picks) == true
      assert DraftPick.available_with_skipped_picks?(next_pick.id, draft_picks) == true
      assert DraftPick.available_with_skipped_picks?(not_available.id, draft_picks) == false
    end

    test "returns whether the pick is available to make when next pick" do
      team_a = %{over_draft_time_limit?: false}
      team_b = %{over_draft_time_limit?: false}
      team_c = %{over_draft_time_limit?: false}

      completed_pick = %{id: 1, draft_position: 1, fantasy_player_id: 1, fantasy_team: team_a}
      next_pick = %{id: 2, draft_position: 2, fantasy_player_id: nil, fantasy_team: team_b}
      not_available = %{id: 3, draft_position: 3, fantasy_player_id: nil, fantasy_team: team_c}

      draft_picks = [completed_pick, next_pick, not_available]

      assert DraftPick.available_with_skipped_picks?(completed_pick.id, draft_picks) == false
      assert DraftPick.available_with_skipped_picks?(next_pick.id, draft_picks) == true
      assert DraftPick.available_with_skipped_picks?(not_available.id, draft_picks) == false
    end

    test "returns false when no pick is available to make" do
      team_a = %{over_draft_time_limit?: false}

      completed_pick = %{id: 1, draft_position: 1, fantasy_player_id: 1, fantasy_team: team_a}

      draft_picks = [completed_pick]

      assert DraftPick.available_with_skipped_picks?(completed_pick.id, draft_picks) == false
    end
  end

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
    test "with valid attributes" do
      changeset = DraftPick.owner_changeset(%DraftPick{}, @valid_user_attrs)
      assert changeset.valid?
    end

    test "adds drafted_at when owner submits draft pick" do
      changeset = DraftPick.owner_changeset(%DraftPick{}, @valid_user_attrs)
      refute changeset.changes.drafted_at == nil
    end

    test "only allows update to fantasy player" do
      changeset = DraftPick.owner_changeset(%DraftPick{}, @valid_user_attrs)
      assert Map.keys(changeset.changes) == [:drafted_at, :fantasy_player_id]
    end

    test "with invalid attributes" do
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

    test "invalid if pick is early in order" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      _player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)

      _first_pick =
        insert(:draft_pick, fantasy_league: league, fantasy_team: team_a, draft_position: 1.01)

      second_pick =
        insert(:draft_pick, fantasy_league: league, fantasy_team: team_b, draft_position: 1.02)

      attrs = %{
        fantasy_player_id: player_b.id
      }

      changeset = DraftPick.owner_changeset(second_pick, attrs)

      refute changeset.valid?
    end

    test "valid if pick is in order" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      _player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)

      first_pick =
        insert(:draft_pick, fantasy_league: league, fantasy_team: team_a, draft_position: 1.01)

      _second_pick =
        insert(:draft_pick, fantasy_league: league, fantasy_team: team_b, draft_position: 1.02)

      attrs = %{
        fantasy_player_id: player_b.id
      }

      changeset = DraftPick.owner_changeset(first_pick, attrs)

      assert changeset.valid?
    end

    test "invalid if pick has already been made" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      player_a = insert(:fantasy_player, sports_league: sport)

      completed_pick =
        insert(:draft_pick,
          fantasy_league: league,
          fantasy_team: team_a,
          draft_position: 1.01,
          fantasy_player: player_a
        )

      attrs = %{
        fantasy_player_id: player_a.id
      }

      changeset = DraftPick.owner_changeset(completed_pick, attrs)

      refute changeset.valid?
    end

    test "valid if pick is available due to skips" do
      league = insert(:fantasy_league, max_draft_hours: 1)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)
      player_c = insert(:fantasy_player, sports_league: sport)

      _completed_first_pick =
        insert(:draft_pick,
          fantasy_league: league,
          fantasy_team: team_a,
          draft_position: 1.01,
          drafted_at: CalendarAssistant.days_from_now(-1),
          fantasy_player: player_a
        )

      _completed_second_pick =
        insert(:draft_pick,
          fantasy_league: league,
          fantasy_team: team_a,
          draft_position: 1.02,
          drafted_at: CalendarAssistant.days_from_now(0),
          fantasy_player: player_b
        )

      _third_pick =
        insert(:draft_pick, fantasy_league: league, fantasy_team: team_a, draft_position: 1.03)

      _fourth_pick =
        insert(:draft_pick, fantasy_league: league, fantasy_team: team_a, draft_position: 1.04)

      fifth_pick =
        insert(:draft_pick, fantasy_league: league, fantasy_team: team_b, draft_position: 1.05)

      attrs = %{
        fantasy_player_id: player_c.id
      }

      %{fantasy_teams: [b, a]} = DraftPick.Store.get_picks_for_league(league.id)

      assert a.over_draft_time_limit? == true
      assert b.over_draft_time_limit? == false

      changeset = DraftPick.owner_changeset(fifth_pick, attrs)

      assert changeset.valid?
    end
  end
end
