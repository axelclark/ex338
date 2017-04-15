defmodule Ex338.InSeasonDraftPick.AdminTest do
  use Ex338.ModelCase

  alias Ex338.{InSeasonDraftPick.Admin}
  alias Ecto.Multi

  describe "update/2" do
    test "with valid player, returns a multi with valid changeset" do
      in_season_draft_pick = insert(:in_season_draft_pick)
      player = insert(:fantasy_player)
      params = %{"drafted_player_id" => player.id}

      multi = Admin.update(in_season_draft_pick, params)

      assert [
        {:update_pick, {:update, changeset, []}},
        {:update_position, {:update, old_pos_changeset, []}},
        {:new_position, {:insert, new_pos_changeset, []}},
        {:email, {:run, _function}}
      ] = Multi.to_list(multi)

      assert changeset.valid?
      assert old_pos_changeset.valid?
      assert new_pos_changeset.valid?
    end

    test "with blank player, returns a multi with an invalid changeset" do
      in_season_draft_pick = insert(:in_season_draft_pick)
      params = %{"drafted_player_id" => ""}

      multi = Admin.update(in_season_draft_pick, params)

      assert [
        {:update_pick, {:update, changeset, []}},
        {:update_position, {:update, old_pos_changeset, []}},
        {:new_position, {:insert, _new_pos_changeset, []}},
        {:email, {:run, _function}}
      ] = Multi.to_list(multi)

      refute changeset.valid?
      assert old_pos_changeset.valid?
    end
  end
end
