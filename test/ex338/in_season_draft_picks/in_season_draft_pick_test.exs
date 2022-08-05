defmodule Ex338.InSeasonDraftPicks.InSeasonDraftPickTest do
  use Ex338.DataCase, async: true

  alias Ex338.{InSeasonDraftPicks, InSeasonDraftPicks.InSeasonDraftPick, CalendarAssistant}

  @valid_attrs %{position: 42, fantasy_league_id: 1, draft_pick_asset_id: 1, championship_id: 2}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = InSeasonDraftPick.changeset(%InSeasonDraftPick{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = InSeasonDraftPick.changeset(%InSeasonDraftPick{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "owner_changeset/2" do
    test "owner_changeset with valid attributes and adds drafted_at" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)

      championship =
        insert(:championship,
          sports_league: sport,
          max_draft_mins: 5,
          draft_starts_at: CalendarAssistant.mins_from_now(-8)
        )

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      player = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      in_season_draft_pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          championship: championship,
          draft_pick_asset: pick_asset
        )

      in_season_draft_pick = InSeasonDraftPicks.pick_with_assocs(in_season_draft_pick.id)

      changeset =
        InSeasonDraftPick.owner_changeset(in_season_draft_pick, %{
          drafted_player_id: player.id
        })

      assert changeset.valid?
      assert %{drafted_at: _} = changeset.changes
    end

    test "owner_changeset only allows update to fantasy player" do
      drafted_player = insert(:fantasy_player, draft_pick: false)
      in_season_draft_pick = insert(:in_season_draft_pick, position: 2)

      in_season_draft_pick = InSeasonDraftPicks.pick_with_assocs(in_season_draft_pick.id)

      attrs = %{drafted_player_id: drafted_player.id, order: 1}
      changeset = InSeasonDraftPick.owner_changeset(in_season_draft_pick, attrs)

      assert %{drafted_player_id: _, drafted_at: _} = changeset.changes
    end

    test "owner_changeset with invalid attributes" do
      in_season_draft_pick = insert(:in_season_draft_pick)
      in_season_draft_pick = InSeasonDraftPicks.pick_with_assocs(in_season_draft_pick.id)

      changeset = InSeasonDraftPick.owner_changeset(in_season_draft_pick, @invalid_attrs)

      refute changeset.valid?
    end

    test "valid if next pick" do
      league = insert(:fantasy_league)

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      drafted_player = insert(:fantasy_player, draft_pick: false)

      insert(
        :in_season_draft_pick,
        draft_pick_asset: pick_asset,
        position: 1,
        drafted_player: drafted_player
      )

      team_b = insert(:fantasy_team, fantasy_league: league)
      pick_b = insert(:fantasy_player, draft_pick: true)
      pick_asset_b = insert(:roster_position, fantasy_team: team_b, fantasy_player: pick_b)
      next_pick = insert(:in_season_draft_pick, draft_pick_asset: pick_asset_b, position: 2)

      player = insert(:fantasy_player, draft_pick: false)
      attrs = %{drafted_player_id: player.id}

      changeset = InSeasonDraftPick.owner_changeset(next_pick, attrs)

      assert changeset.valid?
    end

    test "invalid if not next pick" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)

      championship =
        insert(:championship,
          sports_league: sport,
          max_draft_mins: 5,
          draft_starts_at: CalendarAssistant.mins_from_now(-3)
        )

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)

      insert(
        :in_season_draft_pick,
        draft_pick_asset: pick_asset,
        position: 1,
        championship: championship
      )

      team_b = insert(:fantasy_team, fantasy_league: league)
      pick_b = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset_b = insert(:roster_position, fantasy_team: team_b, fantasy_player: pick_b)

      future_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset_b,
          position: 2,
          championship: championship
        )

      player = insert(:fantasy_player, draft_pick: false)
      attrs = %{drafted_player_id: player.id}

      changeset = InSeasonDraftPick.owner_changeset(future_pick, attrs)

      refute changeset.valid?
    end

    test "valid if not next pick but previous pick is over time limit" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)

      championship =
        insert(:championship,
          sports_league: sport,
          max_draft_mins: 5,
          draft_starts_at: CalendarAssistant.mins_from_now(-8)
        )

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      player = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      insert(
        :in_season_draft_pick,
        position: 1,
        championship: championship,
        draft_pick_asset: pick_asset,
        drafted_player: player,
        drafted_at: CalendarAssistant.mins_from_now(-7)
      )

      next_pick = insert(:fantasy_player, draft_pick: true)
      next_pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: next_pick)

      insert(
        :in_season_draft_pick,
        position: 2,
        fantasy_league: league,
        championship: championship,
        draft_pick_asset: next_pick_asset
      )

      team_b = insert(:fantasy_team, fantasy_league: league)
      future_pick = insert(:fantasy_player, draft_pick: true)

      future_pick_asset =
        insert(:roster_position, fantasy_team: team_b, fantasy_player: future_pick)

      future_pick =
        insert(
          :in_season_draft_pick,
          position: 3,
          fantasy_league: league,
          championship: championship,
          draft_pick_asset: future_pick_asset
        )

      player_to_draft = insert(:fantasy_player, draft_pick: false)
      attrs = %{drafted_player_id: player_to_draft.id}

      changeset = InSeasonDraftPick.owner_changeset(future_pick, attrs)

      assert changeset.valid?
    end

    test "valid if player drafted in another fantasy league" do
      league = insert(:fantasy_league)

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      drafted_player = insert(:fantasy_player, draft_pick: false)

      insert(
        :in_season_draft_pick,
        fantasy_league: league,
        draft_pick_asset: pick_asset,
        position: 1,
        drafted_player: drafted_player
      )

      other_league = insert(:fantasy_league)

      team_b = insert(:fantasy_team, fantasy_league: other_league)
      pick_b = insert(:fantasy_player, draft_pick: true)
      pick_asset_b = insert(:roster_position, fantasy_team: team_b, fantasy_player: pick_b)

      next_pick =
        insert(:in_season_draft_pick,
          fantasy_league: other_league,
          draft_pick_asset: pick_asset_b,
          position: 2
        )

      attrs = %{drafted_player_id: drafted_player.id}

      changeset = InSeasonDraftPick.owner_changeset(next_pick, attrs)

      assert {:ok, _result} = Repo.update(changeset)
    end

    test "error if player already drafted in fantasy league" do
      league = insert(:fantasy_league)

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      drafted_player = insert(:fantasy_player, draft_pick: false)

      insert(
        :in_season_draft_pick,
        fantasy_league: league,
        draft_pick_asset: pick_asset,
        position: 1,
        drafted_player: drafted_player
      )

      team_b = insert(:fantasy_team, fantasy_league: league)
      pick_b = insert(:fantasy_player, draft_pick: true)
      pick_asset_b = insert(:roster_position, fantasy_team: team_b, fantasy_player: pick_b)

      next_pick =
        insert(:in_season_draft_pick,
          fantasy_league: league,
          draft_pick_asset: pick_asset_b,
          position: 2
        )

      attrs = %{drafted_player_id: drafted_player.id}

      changeset = InSeasonDraftPick.owner_changeset(next_pick, attrs)

      assert {:error, result} = Repo.update(changeset)

      assert result.errors == [
               drafted_player_id:
                 {"Player already drafted in the league",
                  [
                    constraint: :unique,
                    constraint_name:
                      "in_season_draft_picks_fantasy_league_id_drafted_player_id_index"
                  ]}
             ]
    end
  end

  describe "by_sport/2" do
    test "returns draft picks for a sport" do
      sport_a = insert(:sports_league)
      sport_b = insert(:sports_league)
      championship_a = insert(:championship, sports_league: sport_a)
      championship_b = insert(:championship, sports_league: sport_b)
      draft_a = insert(:in_season_draft_pick, championship: championship_a)
      _draft_b = insert(:in_season_draft_pick, championship: championship_b)

      result =
        InSeasonDraftPick
        |> InSeasonDraftPick.by_sport(sport_a.id)
        |> Repo.one()

      assert result.id == draft_a.id
    end
  end

  describe "preload assocs by league" do
    test "preloads all associations by fantasy league" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      pick_owner = insert(:owner, fantasy_team: team)
      pick = insert(:fantasy_player, draft_pick: true)
      player = insert(:fantasy_player, draft_pick: false)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)

      insert(
        :in_season_draft_pick,
        drafted_player: player,
        draft_pick_asset: pick_asset
      )

      league_b = insert(:fantasy_league)
      team_b = insert(:fantasy_team, fantasy_league: league_b)
      pick_b = insert(:fantasy_player, draft_pick: true)
      player_b = insert(:fantasy_player, draft_pick: false)
      pick_asset_b = insert(:roster_position, fantasy_team: team_b, fantasy_player: pick_b)

      insert(
        :in_season_draft_pick,
        drafted_player: player_b,
        draft_pick_asset: pick_asset_b
      )

      [result] =
        InSeasonDraftPick
        |> InSeasonDraftPick.preload_assocs_by_league(league.id)
        |> Repo.all()

      [owner] = result.draft_pick_asset.fantasy_team.owners

      assert result.draft_pick_asset.fantasy_team.id == team.id
      assert result.drafted_player.id == player.id
      assert owner.id == pick_owner.id
    end
  end

  describe "preload assocs" do
    test "preloads all associations" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      pick_owner = insert(:owner, fantasy_team: team)
      pick = insert(:fantasy_player, draft_pick: true)
      player = insert(:fantasy_player, draft_pick: false)
      championship = insert(:championship)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)

      insert(
        :in_season_draft_pick,
        drafted_player: player,
        draft_pick_asset: pick_asset,
        championship: championship
      )

      [result] =
        InSeasonDraftPick
        |> InSeasonDraftPick.preload_assocs()
        |> Repo.all()

      [owner] = result.draft_pick_asset.fantasy_team.owners

      assert result.draft_pick_asset.fantasy_team.id == team.id
      assert result.draft_pick_asset.championship_slots == []
      assert Enum.count(result.draft_pick_asset.in_season_draft_picks) == 1
      assert result.drafted_player.id == player.id
      assert result.championship.id == championship.id
      assert owner.id == pick_owner.id
    end
  end

  describe "draft_order/1" do
    test "returns draft picks in descending order" do
      insert(:in_season_draft_pick, position: 5)
      insert(:in_season_draft_pick, position: 4)
      insert(:in_season_draft_pick, position: 10)

      result =
        InSeasonDraftPick
        |> InSeasonDraftPick.draft_order()
        |> Repo.all()
        |> Enum.map(& &1.position)

      assert result == [4, 5, 10]
    end
  end

  describe "reverse_order/1" do
    test "returns draft picks in descending order" do
      insert(:in_season_draft_pick, position: 5)
      insert(:in_season_draft_pick, position: 4)
      insert(:in_season_draft_pick, position: 10)

      result =
        InSeasonDraftPick
        |> InSeasonDraftPick.reverse_order()
        |> Repo.all()
        |> Enum.map(& &1.position)

      assert result == [10, 5, 4]
    end
  end

  describe "player_drafted/1" do
    test "returns draft picks with players drafted" do
      player = insert(:fantasy_player)
      insert(:in_season_draft_pick, position: 5)
      insert(:in_season_draft_pick, position: 4, drafted_player: player)
      insert(:in_season_draft_pick, position: 10)

      result =
        InSeasonDraftPick
        |> InSeasonDraftPick.player_drafted()
        |> Repo.all()
        |> Enum.map(& &1.position)

      assert result == [4]
    end
  end

  describe "no_player_drafted/1" do
    test "returns draft picks without players drafted" do
      player = insert(:fantasy_player)
      insert(:in_season_draft_pick, position: 5)
      insert(:in_season_draft_pick, position: 4, drafted_player: player)
      insert(:in_season_draft_pick, position: 10)

      result =
        InSeasonDraftPick
        |> InSeasonDraftPick.no_player_drafted()
        |> Repo.all()
        |> Enum.map(& &1.position)

      assert result == [5, 10]
    end
  end
end
