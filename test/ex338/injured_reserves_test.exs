defmodule Ex338.InjuredReservesTest do
  use Ex338.DataCase, async: true
  alias Ex338.{InjuredReserves, RosterPositions.RosterPosition}

  describe "get_ir!" do
    test "returns the user with assocs for a given id" do
      team = insert(:fantasy_team)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b
        )

      result = InjuredReserves.get_ir!(ir.id)

      assert result.id == ir.id
      assert result.injured_player.id == player_a.id
      assert result.replacement_player.id == player_b.id
      assert result.fantasy_team.id == team.id
    end
  end

  describe "list_irs_for_league/1" do
    test "returns all waivers with assocs in a league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert_list(2, :injured_reserve, fantasy_team: team)
      insert(:injured_reserve, fantasy_team: other_team)

      result = InjuredReserves.list_irs_for_league(league.id)

      assert Enum.count(result) == 2
    end
  end

  describe "update_injured_reserve/2" do
    test "updates injured reserve status to approved and updates roster_positions" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a)

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b
        )

      attrs = %{"status" => "approved"}

      {:ok,
       %{
         injured_reserve: ir,
         create_replacement_position: new_position,
         update_position_to_injured_reserve: old_position
       }} = InjuredReserves.update_injured_reserve(ir, attrs)

      assert ir.status == :approved
      assert old_position.status == "injured_reserve"
      assert new_position.status == "active"
      assert new_position.acq_method == "injured_reserve"
      assert new_position.fantasy_player_id == player_b.id
    end

    test "returns error when approving an IR, but no roster position found" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b
        )

      attrs = %{"status" => "approved"}

      {:error, :update_position_to_injured_reserve, error, _} =
        InjuredReserves.update_injured_reserve(ir, attrs)

      assert error == "No roster position found for IR."
    end

    test "updates injured reserve status to rejected" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a)

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b
        )

      attrs = %{"status" => "rejected"}

      {:ok,
       %{
         injured_reserve: ir
       }} = InjuredReserves.update_injured_reserve(ir, attrs)

      assert ir.status == :rejected

      old_position = Repo.get_by!(RosterPosition, fantasy_player_id: player_a.id)
      assert old_position.status == "active"
    end

    test "updates injured reserve status to returned and updates roster_positions" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      insert(:roster_position,
        fantasy_team: team,
        fantasy_player: player_a,
        status: "injured_reserve"
      )

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b
        )

      insert(:roster_position,
        fantasy_team: team,
        fantasy_player: player_b,
        status: "active"
      )

      attrs = %{"status" => "returned"}

      {:ok,
       %{
         injured_reserve: ir,
         update_position_to_active: ir_position,
         update_position_to_dropped: replacement_position
       }} = InjuredReserves.update_injured_reserve(ir, attrs)

      assert ir.status == :returned
      assert ir_position.status == "active"
      assert replacement_position.status == "dropped"
    end

    test "updates injured reserve status to returned when positions have been dropped" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      insert(:roster_position,
        fantasy_team: team,
        fantasy_player: player_a,
        status: "dropped"
      )

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b
        )

      insert(:roster_position,
        fantasy_team: team,
        fantasy_player: player_b,
        status: "dropped"
      )

      attrs = %{"status" => "returned"}

      {:ok,
       %{
         injured_reserve: ir
       }} = InjuredReserves.update_injured_reserve(ir, attrs)

      assert ir.status == :returned
    end

    test "updates injured reserve status to returned when positions is taken" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      insert(:roster_position,
        position: "sport",
        fantasy_team: team,
        fantasy_player: player_a,
        status: "injured_reserve"
      )

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b,
          status: "approved"
        )

      insert(:roster_position,
        position: "sport",
        fantasy_team: team,
        fantasy_player: player_b,
        status: "active"
      )

      attrs = %{"status" => "returned"}

      {:ok,
       %{
         injured_reserve: ir
       }} = InjuredReserves.update_injured_reserve(ir, attrs)

      assert ir.status == :returned
    end
  end

  describe "change_injured_reserve/1" do
    test "returns an injured reserve changeset" do
      injured_reserve = insert(:injured_reserve)
      assert %Ecto.Changeset{} = InjuredReserves.change_injured_reserve(injured_reserve)
    end
  end
end
