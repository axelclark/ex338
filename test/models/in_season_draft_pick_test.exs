defmodule Ex338.InSeasonDraftPickTest do
  use Ex338.ModelCase

  alias Ex338.InSeasonDraftPick

  @valid_attrs %{position: 42, draft_pick_asset_id: 1, championship_id: 2}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = InSeasonDraftPick.changeset(%InSeasonDraftPick{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = InSeasonDraftPick.changeset(%InSeasonDraftPick{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "preload assocs by league" do
    test "preloads all associations by fantasy league" do
      league = insert(:fantasy_league)
      team   = insert(:fantasy_team, fantasy_league: league)
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

      assert result.draft_pick_asset.fantasy_team.id == team.id
      assert result.drafted_player.id == player.id
    end
  end

  describe "preload assocs" do
    test "preloads all associations" do
      league = insert(:fantasy_league)
      team   = insert(:fantasy_team, fantasy_league: league)
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

      assert result.draft_pick_asset.fantasy_team.id == team.id
      assert result.drafted_player.id == player.id
      assert result.championship.id == championship.id
    end
  end
end
