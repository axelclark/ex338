defmodule Ex338.DraftPicks.DraftPickTest do
  use Ex338.DataCase, async: true

  alias Ex338.CalendarAssistant
  alias Ex338.DraftPicks
  alias Ex338.DraftPicks.DraftPick

  describe "add_pick_numbers/1" do
    test "Adds pick numbers for a list of draft picks" do
      picks = [
        %DraftPick{},
        %DraftPick{},
        %DraftPick{}
      ]

      result = DraftPick.add_pick_numbers(picks)

      assert Enum.map(result, & &1.pick_number) == [1, 2, 3]
    end
  end

  describe "by_league/2" do
    test "returns draft picks in a league" do
      league = insert(:fantasy_league)
      pick = insert(:draft_pick, fantasy_league: league)
      other_league = insert(:fantasy_league)
      _other_pick = insert(:draft_pick, fantasy_league: other_league)

      result =
        DraftPick
        |> DraftPick.by_league(league.id)
        |> Repo.one()

      assert result.id == pick.id
    end
  end

  describe "last_picks/2" do
    test "returns last X picks in descending order" do
      num_picks = 5
      league = insert(:fantasy_league)
      insert(:submitted_pick, draft_position: 1.04, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.05, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.10, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.15, fantasy_league: league)
      insert(:submitted_pick, draft_position: 1.24, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.30, fantasy_league: league)

      picks =
        DraftPick
        |> DraftPick.last_picks(league.id, num_picks)
        |> Repo.all()
        |> Enum.map(& &1.draft_position)

      assert picks == [1.24, 1.15, 1.1, 1.05, 1.04]
    end
  end

  describe "next_picks/2" do
    test "returns next X picks in descending order" do
      num_picks = 5
      league = insert(:fantasy_league)
      team = insert(:fantasy_team)
      player = insert(:fantasy_player)

      insert(
        :draft_pick,
        draft_position: 1.04,
        fantasy_league: league,
        fantasy_team: team,
        fantasy_player: player
      )

      insert(:draft_pick, draft_position: 1.05, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.10, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.15, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.24, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.30, fantasy_league: league)

      picks =
        DraftPick
        |> DraftPick.next_picks(league.id, num_picks)
        |> Repo.all()
        |> Enum.map(& &1.draft_position)

      assert picks == [1.05, 1.1, 1.15, 1.24, 1.3]
    end
  end

  describe "ordered_by_position/1" do
    test "returns draft picks in descending order" do
      league = insert(:fantasy_league)
      insert(:draft_pick, draft_position: 1.05, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.04, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.10, fantasy_league: league)

      picks =
        DraftPick
        |> DraftPick.ordered_by_position()
        |> Repo.all()
        |> Enum.map(& &1.draft_position)

      assert picks == [1.04, 1.05, 1.1]
    end
  end

  describe "preload_assocs/1" do
    test "returns draft pick with assocs preloaded" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      owner = insert(:owner, fantasy_team: team)
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)

      insert(
        :draft_pick,
        fantasy_league: league,
        fantasy_player: player,
        fantasy_team: team
      )

      result =
        %{fantasy_team: %{owners: [owner_result]}} =
        DraftPick
        |> DraftPick.preload_assocs()
        |> Repo.one()

      assert owner_result.id == owner.id
      assert result.fantasy_player.sports_league.id == sport.id
      assert result.fantasy_league.id == league.id
    end
  end

  describe "reverse_ordered_by_position/1" do
    test "returns draft picks in ascending order" do
      league = insert(:fantasy_league)
      insert(:draft_pick, draft_position: 1.05, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.04, fantasy_league: league)
      insert(:draft_pick, draft_position: 1.10, fantasy_league: league)

      picks =
        DraftPick
        |> DraftPick.reverse_ordered_by_position()
        |> Repo.all()
        |> Enum.map(& &1.draft_position)

      assert picks == [1.1, 1.05, 1.04]
    end
  end

  describe "update_available_to_pick?/2" do
    test "returns whether picks are availble to make with skips" do
      team_a = %{over_draft_time_limit?: false}
      team_b = %{over_draft_time_limit?: true}
      team_c = %{over_draft_time_limit?: true}
      team_d = %{over_draft_time_limit?: false}

      completed_pick = %{
        id: 1,
        draft_position: 1,
        fantasy_player_id: 1,
        fantasy_team: team_a,
        available_to_pick?: false
      }

      skipped_pick = %{
        id: 2,
        draft_position: 2,
        fantasy_player_id: nil,
        fantasy_team: team_b,
        available_to_pick?: false
      }

      skipped_pick2 = %{
        id: 3,
        draft_position: 3,
        fantasy_player_id: nil,
        fantasy_team: team_c,
        available_to_pick?: false
      }

      next_pick = %{
        id: 4,
        draft_position: 4,
        fantasy_player_id: nil,
        fantasy_team: team_d,
        available_to_pick?: false
      }

      not_available = %{
        id: 5,
        draft_position: 5,
        fantasy_player_id: nil,
        fantasy_team: team_a,
        available_to_pick?: false
      }

      draft_picks = [completed_pick, skipped_pick, skipped_pick2, next_pick, not_available]

      results = DraftPick.update_available_to_pick?(draft_picks)

      assert Enum.map(results, & &1.available_to_pick?) == [false, true, true, true, false]
    end

    test "returns whether picks are available to make when next pick" do
      team_a = %{over_draft_time_limit?: false}
      team_b = %{over_draft_time_limit?: false}
      team_c = %{over_draft_time_limit?: false}

      completed_pick = %{
        id: 1,
        draft_position: 1,
        fantasy_player_id: 1,
        fantasy_team: team_a,
        available_to_pick?: false
      }

      next_pick = %{
        id: 2,
        draft_position: 2,
        fantasy_player_id: nil,
        fantasy_team: team_b,
        available_to_pick?: false
      }

      not_available = %{
        id: 3,
        draft_position: 3,
        fantasy_player_id: nil,
        fantasy_team: team_c,
        available_to_pick?: false
      }

      draft_picks = [completed_pick, next_pick, not_available]

      results = DraftPick.update_available_to_pick?(draft_picks)

      assert Enum.map(results, & &1.available_to_pick?) == [false, true, false]
    end

    test "returns false when no pick is available to make" do
      team_a = %{over_draft_time_limit?: false}

      completed_pick = %{
        id: 1,
        draft_position: 1,
        fantasy_player_id: 1,
        fantasy_team: team_a,
        available_to_pick?: false
      }

      draft_picks = [completed_pick]

      results = DraftPick.update_available_to_pick?(draft_picks)

      assert Enum.map(results, & &1.available_to_pick?) == [false]
    end
  end

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

    test "returns availability when skip pick is made" do
      team_a = %{over_draft_time_limit?: false}
      team_b = %{over_draft_time_limit?: true}
      team_c = %{over_draft_time_limit?: true}
      team_d = %{over_draft_time_limit?: false}

      completed_pick = %{id: 1, draft_position: 1, fantasy_player_id: 1, fantasy_team: team_a}
      skipped_pick = %{id: 2, draft_position: 2, fantasy_player_id: nil, fantasy_team: team_b}
      completed_pick2 = %{id: 1, draft_position: 1, fantasy_player_id: 1, fantasy_team: team_c}
      next_pick = %{id: 4, draft_position: 4, fantasy_player_id: nil, fantasy_team: team_d}
      not_available = %{id: 5, draft_position: 5, fantasy_player_id: nil, fantasy_team: team_a}

      draft_picks = [completed_pick, skipped_pick, completed_pick2, next_pick, not_available]

      assert DraftPick.available_with_skipped_picks?(completed_pick.id, draft_picks) == false
      assert DraftPick.available_with_skipped_picks?(skipped_pick.id, draft_picks) == true
      assert DraftPick.available_with_skipped_picks?(completed_pick2.id, draft_picks) == false
      assert DraftPick.available_with_skipped_picks?(next_pick.id, draft_picks) == true
      assert DraftPick.available_with_skipped_picks?(not_available.id, draft_picks) == false
    end
  end

  describe "picks_available_with_skips/1" do
    test "returns available picks to make with skips" do
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

      results = DraftPick.picks_available_with_skips(draft_picks)

      assert Enum.map(results, & &1.id) == [skipped_pick.id, skipped_pick2.id, next_pick.id]
    end

    test "returns nil when no pick is available to make" do
      team_a = %{over_draft_time_limit?: false}

      completed_pick = %{id: 1, draft_position: 1, fantasy_player_id: 1, fantasy_team: team_a}

      draft_picks = [completed_pick]

      assert DraftPick.picks_available_with_skips(draft_picks) == nil
    end

    test "returns available picks when skip pick is made" do
      team_a = %{over_draft_time_limit?: false}
      team_b = %{over_draft_time_limit?: true}
      team_c = %{over_draft_time_limit?: true}
      team_d = %{over_draft_time_limit?: false}

      completed_pick = %{id: 1, draft_position: 1, fantasy_player_id: 1, fantasy_team: team_a}
      skipped_pick = %{id: 2, draft_position: 2, fantasy_player_id: nil, fantasy_team: team_b}
      completed_pick2 = %{id: 1, draft_position: 1, fantasy_player_id: 1, fantasy_team: team_c}
      next_pick = %{id: 4, draft_position: 4, fantasy_player_id: nil, fantasy_team: team_d}
      not_available = %{id: 5, draft_position: 5, fantasy_player_id: nil, fantasy_team: team_a}

      draft_picks = [completed_pick, skipped_pick, completed_pick2, next_pick, not_available]

      results = DraftPick.picks_available_with_skips(draft_picks)

      assert Enum.map(results, & &1.id) == [skipped_pick.id, next_pick.id]
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
      change_keys = changeset.changes |> Map.keys() |> MapSet.new()

      expected_change_keys = MapSet.new([:drafted_at, :fantasy_player_id])
      assert MapSet.equal?(change_keys, expected_change_keys)
    end

    test "with invalid attributes" do
      changeset = DraftPick.owner_changeset(%DraftPick{}, @valid_attrs)
      refute changeset.valid?
    end

    test "error when player already drafted in league" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)
      insert(:draft_pick, fantasy_league: league, fantasy_team: team_a, fantasy_player: player)
      draft_pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team_b)
      draft_pick = Repo.preload(draft_pick, :fantasy_player)
      attrs = %{fantasy_player_id: player.id}

      changeset = DraftPick.owner_changeset(draft_pick, attrs)
      {:error, result} = Repo.update(changeset)

      assert result.errors == [
               fantasy_player_id:
                 {"Player already drafted in the league",
                  [
                    constraint: :unique,
                    constraint_name: "draft_picks_fantasy_league_id_fantasy_player_id_index"
                  ]}
             ]
    end

    test "valid when player drafted in other league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: other_league)
      player = insert(:fantasy_player)

      _first_pick =
        insert(:draft_pick, fantasy_league: league, fantasy_team: team_a, fantasy_player: player)

      draft_pick = insert(:draft_pick, fantasy_league: other_league, fantasy_team: team_b)
      draft_pick = Repo.preload(draft_pick, :fantasy_player)
      attrs = %{fantasy_player_id: player.id}

      changeset = DraftPick.owner_changeset(draft_pick, attrs)
      {:ok, result} = Repo.update(changeset)

      assert changeset.valid?
      assert result.fantasy_player_id == player.id
    end

    test "valid when under max flex slots" do
      league = insert(:fantasy_league, max_flex_spots: 5)
      team = insert(:fantasy_team, fantasy_league: league)
      regular_positions = insert_list(4, :roster_position, fantasy_team: team)

      flex_sport = List.first(regular_positions).fantasy_player.sports_league
      insert(:league_sport, sports_league: flex_sport, fantasy_league: league)

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
      insert(:league_sport, sports_league: flex_sport, fantasy_league: league)

      [add | plyrs] = insert_list(6, :fantasy_player, sports_league: flex_sport)

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

      assert changeset.errors == [
               fantasy_player_id: {"No flex position available for this player", []}
             ]
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

      assert changeset.errors == [
               fantasy_player_id:
                 {"Number of available players equal to number of teams with need", []}
             ]
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

      assert changeset.errors == [
               fantasy_player_id:
                 {"Number of available players equal to number of teams with need", []}
             ]
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

    test "error if available draft pick players equal to teams needing to fill league rosters" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      _team_b = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      player_a = insert(:fantasy_player, sports_league: sport, draft_pick: true)
      player_b = insert(:fantasy_player, sports_league: sport, draft_pick: true)

      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      draft_pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team_a)

      attrs = %{
        fantasy_player_id: player_b.id
      }

      changeset = DraftPick.owner_changeset(draft_pick, attrs)

      refute changeset.valid?

      assert changeset.errors == [
               fantasy_player_id:
                 {"Number of available players equal to number of teams with need", []}
             ]
    end

    test "error if available draft pick players less than teams needing to fill league rosters" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      _team_b = insert(:fantasy_team, fantasy_league: league)
      _team_c = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      player_a = insert(:fantasy_player, sports_league: sport, draft_pick: true)
      player_b = insert(:fantasy_player, sports_league: sport, draft_pick: true)

      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      draft_pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team_a)

      attrs = %{
        fantasy_player_id: player_b.id
      }

      changeset = DraftPick.owner_changeset(draft_pick, attrs)

      refute changeset.valid?

      assert changeset.errors == [
               fantasy_player_id:
                 {"Number of available players equal to number of teams with need", []}
             ]
    end

    test "valid if team needs draft pick player to fill sport position" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      player_a = insert(:fantasy_player, sports_league: sport, draft_pick: true)
      player_b = insert(:fantasy_player, sports_league: sport, draft_pick: true)

      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      draft_pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team_b)

      attrs = %{
        fantasy_player_id: player_b.id
      }

      changeset = DraftPick.owner_changeset(draft_pick, attrs)

      assert changeset.valid?
    end

    test "no error when league has must_draft_each_sport? as false" do
      league = insert(:fantasy_league, must_draft_each_sport?: false)
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

      %{fantasy_teams: [b, a]} = DraftPicks.get_picks_for_league(league.id)

      assert a.over_draft_time_limit? == true
      assert b.over_draft_time_limit? == false

      changeset = DraftPick.owner_changeset(fifth_pick, attrs)

      assert changeset.valid?
    end
  end
end
