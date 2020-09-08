defmodule Ex338.InjuredReservesTest do
  use Ex338.DataCase, async: true
  alias Ex338.InjuredReserves

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

  describe "process_ir/2" do
    @attrs %{"status" => "approved"}

    test "updates repo with successful injured reserve add claim " do
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

      {:ok, %{ir: ir}} = InjuredReserves.process_ir(ir.id, @attrs)

      assert ir.status == "approved"
      positions = Repo.all(Ex338.RosterPositions.RosterPosition)
      assert Enum.count(positions) == 2
    end

    test "updates repo with successful injured reserve remove claim " do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      player_c = insert(:fantasy_player)

      insert(
        :roster_position,
        fantasy_team: team,
        fantasy_player: player_a,
        position: "WTn",
        status: "injured_reserve"
      )

      insert(:roster_position, fantasy_team: team, fantasy_player: player_b, position: "Flex1")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_c, position: "WTn")

      ir =
        insert(
          :injured_reserve,
          fantasy_team: team,
          replacement_player: player_b
        )

      {:ok, %{ir: ir}} = InjuredReserves.process_ir(ir.id, @attrs)

      assert ir.status == "approved"
      positions = Repo.all(Ex338.RosterPositions.RosterPosition)
      assert Enum.count(positions) == 3
    end

    test "returns error on remove if position is not found for replacement" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      insert(
        :roster_position,
        fantasy_team: team,
        fantasy_player: player_a,
        status: "injured_reserve"
      )

      ir =
        insert(
          :injured_reserve,
          remove_player: player_a,
          fantasy_team: team,
          replacement_player: player_b
        )

      {:error, message} = InjuredReserves.process_ir(ir.id, @attrs)

      assert message == "RosterPosition for IR not found"
    end

    test "returns error on add if position is not found for IR" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      ir =
        insert(
          :injured_reserve,
          remove_player: player_a,
          fantasy_team: team,
          replacement_player: player_b
        )

      {:error, message} = InjuredReserves.process_ir(ir.id, @attrs)

      assert message == "RosterPosition for IR not found"
    end
  end
end
