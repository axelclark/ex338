defmodule Ex338.InSeasonDraftPick.AdminTest do
  use Ex338.ModelCase

  alias Ex338.{InSeasonDraftPick.Admin}
  alias Ecto.Multi

  describe "update/2" do
    test "with successful status, returns a multi with valid changeset" do
      in_season_draft_pick = insert(:in_season_draft_pick)
      player = insert(:fantasy_player)
      params = %{"drafted_player_id" => player.id}

      multi = Admin.update(in_season_draft_pick, params)

      assert [
        {:in_season_draft_pick, {:update, changeset, []}},
        {:email, {:run, _function}}
      ] = Multi.to_list(multi)

      assert changeset.valid?
    end

    test "with unsuccessful status, returns a multi with valid changeset" do
      in_season_draft_pick = insert(:in_season_draft_pick)
      params = %{"drafted_player_id" => nil}

      multi = Admin.update(in_season_draft_pick, params)

      assert [
        {:in_season_draft_pick, {:update, changeset, []}},
        {:email, {:run, _function}}
      ] = Multi.to_list(multi)

      refute changeset.valid?
    end
  end
end
