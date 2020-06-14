defmodule Ex338.Championships.CreateSlotTest do
  use Ex338.DataCase, async: true
  alias Ex338.{Championships.CreateSlot, Championships.ChampionshipSlot, FantasyTeams.FantasyTeam, Repo}

  describe "create_slots_from_positions/1" do
    test "creates roster slots from positions" do
      sport = insert(:sports_league)
      championship = insert(:championship, category: "event", sports_league: sport)
      player_a = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)
      player_c = insert(:fantasy_player, sports_league: sport)
      team = insert(:fantasy_team)
      other_team = insert(:fantasy_team)
      _no_pos_team = insert(:fantasy_team)

      primary =
        insert(
          :roster_position,
          fantasy_player: player_a,
          fantasy_team: team,
          status: "active",
          position: "CBB"
        )

      flex =
        insert(
          :roster_position,
          fantasy_player: player_b,
          fantasy_team: team,
          status: "active",
          position: "Flex1"
        )

      ua =
        insert(
          :roster_position,
          fantasy_player: player_c,
          fantasy_team: other_team,
          status: "active",
          position: "Unassigned"
        )

      teams =
        FantasyTeam
        |> preload(:roster_positions)
        |> Repo.all()

      {:ok, _results} = CreateSlot.create_slots_from_positions(teams, championship.id)
      slots = Repo.all(ChampionshipSlot)

      assert Enum.map(slots, & &1.roster_position_id) == [primary.id, flex.id, ua.id]
    end
  end

  describe "create_slots_for_team/1" do
    test "calculates the slot for a champioship based on roster position" do
      team = %{
        roster_positions: [
          %{position: "Flex1"},
          %{position: "Flex2"},
          %{position: "MTn"}
        ]
      }

      result = CreateSlot.calculate_slots_for_team(team)

      assert result ==
               %{
                 roster_positions: [
                   %{position: "MTn", slot: 1},
                   %{position: "Flex1", slot: 2},
                   %{position: "Flex2", slot: 3}
                 ]
               }
    end
  end
end
