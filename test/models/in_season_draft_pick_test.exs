defmodule Ex338.InSeasonDraftPickTest do
  use Ex338.ModelCase

  alias Ex338.InSeasonDraftPick

  @valid_attrs %{position: 42, draft_pick_asset_id: 1, championship_id: 2}
  @valid_owner_attrs %{drafted_player_id: 5}
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
    test "owner_changeset with valid attributes" do
      changeset =
        InSeasonDraftPick.owner_changeset(%InSeasonDraftPick{}, @valid_owner_attrs)
      assert changeset.valid?
    end

    test "owner_changeset only allows update to fantasy player" do
      attrs = Map.merge(@valid_attrs, @valid_owner_attrs)
      changeset = InSeasonDraftPick.owner_changeset(%InSeasonDraftPick{}, attrs)
      assert changeset.changes == %{drafted_player_id: 5}
    end

    test "owner_changeset with invalid attributes" do
      changeset =
        InSeasonDraftPick.owner_changeset(%InSeasonDraftPick{}, @invalid_attrs)
      refute changeset.valid?
    end
  end

  describe "preload assocs by league" do
    test "preloads all associations by fantasy league" do
      league = insert(:fantasy_league)
      team   = insert(:fantasy_team, fantasy_league: league)
      pick_owner  = insert(:owner, fantasy_team: team)
      pick   = insert(:fantasy_player, draft_pick: true)
      player = insert(:fantasy_player, draft_pick: false)
      pick_asset =
        insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      insert(:in_season_draft_pick, drafted_player: player,
        draft_pick_asset: pick_asset)

      league_b = insert(:fantasy_league)
      team_b   = insert(:fantasy_team, fantasy_league: league_b)
      pick_b   = insert(:fantasy_player, draft_pick: true)
      player_b = insert(:fantasy_player, draft_pick: false)
      pick_asset_b =
        insert(:roster_position, fantasy_team: team_b, fantasy_player: pick_b)
      insert(:in_season_draft_pick, drafted_player: player_b,
        draft_pick_asset: pick_asset_b)

      [result] =
        InSeasonDraftPick
        |> InSeasonDraftPick.preload_assocs_by_league(league.id)
        |> Repo.all

      [owner] = result.draft_pick_asset.fantasy_team.owners

      assert result.draft_pick_asset.fantasy_team.id == team.id
      assert result.drafted_player.id == player.id
      assert owner.id == pick_owner.id
    end
  end

  describe "preload assocs" do
    test "preloads all associations" do
      league = insert(:fantasy_league)
      team   = insert(:fantasy_team, fantasy_league: league)
      pick_owner  = insert(:owner, fantasy_team: team)
      pick   = insert(:fantasy_player, draft_pick: true)
      player = insert(:fantasy_player, draft_pick: false)
      championship = insert(:championship)
      pick_asset =
        insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      insert(:in_season_draft_pick, drafted_player: player,
        draft_pick_asset: pick_asset, championship: championship)

      [result] =
        InSeasonDraftPick
        |> InSeasonDraftPick.preload_assocs
        |> Repo.all

      [owner] = result.draft_pick_asset.fantasy_team.owners

      assert result.draft_pick_asset.fantasy_team.id == team.id
      assert result.drafted_player.id == player.id
      assert result.championship.id == championship.id
      assert owner.id == pick_owner.id
    end
  end

  describe "next_pick?/1" do
    test "updates next pick for list of in season draft picks" do
      completed_pick = %InSeasonDraftPick{position: 1, drafted_player_id: 1}
      next_pick = %InSeasonDraftPick{position: 2, drafted_player_id: nil}
      future_pick = %InSeasonDraftPick{position: 3, drafted_player_id: nil}
      draft_picks = [completed_pick, next_pick, future_pick]

      [complete, next, future] =
        InSeasonDraftPick.update_next_pick(draft_picks)

      assert complete.next_pick == false
      assert next.next_pick == true
      assert future.next_pick == false
    end

    test "all picks are false if draft is over" do
      completed_pick = %InSeasonDraftPick{position: 1, drafted_player_id: 1}
      next_pick = %InSeasonDraftPick{position: 2, drafted_player_id: 2}
      future_pick = %InSeasonDraftPick{position: 3, drafted_player_id: 3}
      draft_picks = [completed_pick, next_pick, future_pick]

      [complete, next, future] =
        InSeasonDraftPick.update_next_pick(draft_picks)

      assert complete.next_pick == false
      assert next.next_pick == false
      assert future.next_pick == false
    end
  end
end
