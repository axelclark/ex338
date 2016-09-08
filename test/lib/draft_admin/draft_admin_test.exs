defmodule Ex338.DraftPickAdminTest do
  use Ex338.ModelCase
  alias Ex338.{DraftPickAdmin}

  describe "draft_player/1" do
    test "dry run draft_player ecto multi" do
      draft_pick = build(:draft_pick, fantasy_team_id: 2, fantasy_league_id: 1)
      params = %{"fantasy_player_id" => 1}

      multi = DraftPickAdmin.draft_player(draft_pick, params)

      assert [
        {:draft_pick, {:update, _draft_pick_changeset, []}},
        {:roster_position, {:insert, _roster_position_changeset, []}}
      ] = Ecto.Multi.to_list(multi)
    end
  end
end
