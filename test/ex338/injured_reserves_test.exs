defmodule Ex338.InjuredReservesTest do
  use Ex338.DataCase, async: true

  alias Ex338.{
    CalendarAssistant,
    InjuredReserves,
    InjuredReserves.InjuredReserve,
    RosterPositions.RosterPosition
  }

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
    test "returns all injured_reserves with assocs in a league" do
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

  describe "list_injured_reserves/0" do
    test "returns all injured_reserves" do
      insert_list(2, :injured_reserve)
      result = InjuredReserves.list_injured_reserves()

      assert Enum.count(result) == 2
    end
  end

  describe "list_injured_reserves/1" do
    test "returns all injured_reserves with assocs in a league from id" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert_list(2, :injured_reserve, fantasy_team: team)
      insert(:injured_reserve, fantasy_team: other_team)

      result = InjuredReserves.list_injured_reserves(fantasy_league_id: league.id)

      assert Enum.count(result) == 2
    end

    test "returns all injured_reserves with assocs in a league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert_list(2, :injured_reserve, fantasy_team: team)
      insert(:injured_reserve, fantasy_team: other_team)

      result = InjuredReserves.list_injured_reserves(fantasy_league: league)

      assert Enum.count(result) == 2
    end

    test "returns all injured_reserves by status" do
      insert(:injured_reserve, status: :submitted)
      insert(:injured_reserve, status: :approved)
      insert(:injured_reserve, status: :returned)
      insert(:injured_reserve, status: :rejected)

      result = InjuredReserves.list_injured_reserves(statuses: [:submitted, :approved])

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

  describe "create_injured_reserve/2" do
    test "creates an injured reserve from a team and attributes" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)

      insert(
        :championship,
        sports_league: sports_league,
        championship_at: CalendarAssistant.days_from_now(1)
      )

      player_a = insert(:fantasy_player, sports_league: sports_league)
      player_b = insert(:fantasy_player, sports_league: sports_league)
      insert(:roster_position, fantasy_player: player_a, fantasy_team: team)
      attrs = %{"injured_player_id" => player_a.id, "replacement_player_id" => player_b.id}

      {:ok, %InjuredReserve{} = result} = InjuredReserves.create_injured_reserve(team, attrs)

      assert result.status == "submitted"
      assert result.injured_player_id == player_a.id
      assert result.replacement_player_id == player_b.id
    end

    test "returns an error and changeset with invalid attrs" do
      team = insert(:fantasy_team)
      attrs = %{"injured_player_id" => nil, "replacement_player_id" => nil}

      {:error, %Ecto.Changeset{} = changeset} =
        InjuredReserves.create_injured_reserve(team, attrs)

      refute changeset.valid?
    end
  end
end
