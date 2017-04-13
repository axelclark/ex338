defmodule Ex338.InSeasonDraftPick.StoreTest do
  use Ex338.ModelCase

  alias Ex338.InSeasonDraftPick.Store

  describe "pick_with_assocs/1" do
    test "returns in season draft picks with associations" do
      player = insert(:fantasy_player, draft_pick: false)
      pick = insert(:in_season_draft_pick, drafted_player: player)

      %{
        id: id,
        draft_pick_asset: %{fantasy_team: %{}, fantasy_player: %{}},
        drafted_player: %{id: _drafted_player_id},
        championship: %{id: _championship_id}
      } = Store.pick_with_assocs(pick.id)

      assert id == pick.id
    end
  end

  describe "owner_changeset/1" do
    test "returns changeset for owner update" do
      pick = insert(:in_season_draft_pick)

      changeset = Store.changeset(pick)

      assert changeset.valid?
    end
  end

  describe "available_players/1" do
    test "returns available players to draft" do
      league = insert(:fantasy_league)
      league_b = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league_b)

      sport = insert(:sports_league)
      champ = insert(:championship, sports_league: sport)

      pick_player =
        insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset =
        insert(:roster_position, fantasy_team: team, fantasy_player: pick_player)
      pick =
        insert(:in_season_draft_pick, position: 1, draft_pick_asset: pick_asset,
          championship: champ)

      drafted_player =
        insert(:fantasy_player, draft_pick: false, sports_league: sport)
      insert(:roster_position, fantasy_team: team, fantasy_player: drafted_player)
      avail_player =
        insert(:fantasy_player, draft_pick: false, sports_league: sport)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: avail_player)

      pick = Store.pick_with_assocs(pick.id)
      [result] = Store.available_players(pick)

      assert result.id == avail_player.id
    end
  end

  describe "make_pick/2" do
    test "updates a in season draft pick with a fantasy player" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      championship = insert(:championship)
      pick_player = insert(:fantasy_player, draft_pick: true)
      player = insert(:fantasy_player, draft_pick: false)
      pick_asset =
        insert(:roster_position, fantasy_team: team, fantasy_player: pick_player)
      pick =
        insert(:in_season_draft_pick, position: 1, draft_pick_asset: pick_asset,
          championship: championship)
      params = %{"drafted_player_id" => player.id}

      {:ok, %{in_season_draft_pick: updated_pick}} =
        Store.draft_player(pick, params)

      assert updated_pick.drafted_player_id == player.id
    end

    test "does not update and returns errors when invalid" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)

      championship = insert(:championship)
      pick_player = insert(:fantasy_player, draft_pick: true)
      pick_asset =
        insert(:roster_position, fantasy_team: team, fantasy_player: pick_player)
      pick =
        insert(:in_season_draft_pick, position: 1, draft_pick_asset: pick_asset,
          championship: championship)
      params = %{"drafted_player_id" => nil}

      {:error, :in_season_draft_pick, changeset,_} =
        Store.draft_player(pick, params)

      assert changeset.errors ==
        [drafted_player_id: {"can't be blank", [validation: :required]}]
    end
  end
end
