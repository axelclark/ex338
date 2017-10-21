defmodule Ex338.InjuredReserve.AdminTest do
  use Ex338.DataCase
  alias Ex338.{InjuredReserve, RosterPosition, InjuredReserve.Admin}
  alias Ecto.Multi

  @ir %InjuredReserve{
    status: "pending",
    fantasy_team_id: 1,
    add_player_id: nil,
    remove_player_id: nil,
    replacement_player_id: 3,
  }

  @active_position %RosterPosition{
    id: 4, fantasy_team_id: 1, fantasy_player_id: 2, status: "active"
  }

  @ir_position %RosterPosition{
    id: 4, fantasy_team_id: 1, fantasy_player_id: 2, status: "injured_reserve"
  }

  @replacement_position %RosterPosition{
    id: 5, fantasy_team_id: 1, fantasy_player_id: 3, status: "active"
  }

  describe "process_ir/3" do
    test "approval of add player to IR returns a multi with valid changeset" do
      ir = %{@ir | add_player_id: 2}
      params = %{"status" => "approved"}
      positions = %{ir: @active_position}

      multi = Admin.process_ir({:add, ir}, params, positions)

      assert [
        {:ir, {:update, ir_changeset, []}},
        {:active_to_ir, {:update, pos_changeset, []}},
        {:add_replacement, {:insert, new_pos_changeset, []}}
      ] = Multi.to_list(multi)

      assert ir_changeset.valid?
      assert pos_changeset.valid?
      assert new_pos_changeset.valid?
    end

    test "approval of remove player from IR returns multi with valid changeset" do
      ir = %{@ir | remove_player_id: 2}
      params = %{"status" => "approved"}
      positions = %{ir: @ir_position, replacement: @replacement_position}

      multi = Admin.process_ir({:remove, ir}, params, positions)

      assert [
        {:ir, {:update, ir_changeset, []}},
        {:ir_to_active, {:update, pos_changeset, []}},
        {:drop_replacement, {:update, drop_pos_changeset, []}}
      ] = Multi.to_list(multi)

      assert ir_changeset.valid?
      assert pos_changeset.valid?
      assert drop_pos_changeset.valid?
    end
  end
end
