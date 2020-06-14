defmodule Ex338.DraftPicks.AdminTest do
  use Ex338.DataCase, async: true

  describe "draft_player/1" do
    test "dry run draft_player ecto multi" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      draft_pick = insert(:draft_pick, fantasy_team: team, fantasy_league: league)
      player = insert(:fantasy_player)
      params = %{"fantasy_player_id" => player.id}

      multi = Ex338.DraftPicks.Admin.draft_player(draft_pick, params)

      assert [
               {:draft_pick, {:update, _draft_pick_changeset, []}},
               {:roster_position, {:insert, _roster_position_changeset, []}},
               {:unavailable_draft_queues, {:update_all, _, [], returning: true}},
               {:drafted_draft_queues, {:update_all, _, [], returning: true}}
             ] = Ecto.Multi.to_list(multi)
    end
  end
end
