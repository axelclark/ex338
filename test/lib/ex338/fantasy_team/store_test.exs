defmodule Ex338.FantasyTeam.StoreTest do
  use Ex338.ModelCase
  alias Ex338.FantasyTeam.Store

  describe "find/1" do
    test "returns team with assocs and calculated fields" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league,
                                   winnings_received: 75, dues_paid: 100)
      user = insert_user(%{name: "Axel"})
      insert(:owner, user: user, fantasy_team: team)
      player = insert(:fantasy_player, player_name: "Houston")
      dropped_player = insert(:fantasy_player)
      ir_player = insert(:fantasy_player)
      insert(:roster_position, position: "Unassigned", fantasy_team: team,
                                          fantasy_player: player)
      insert(:roster_position, fantasy_team: team,
                               fantasy_player: dropped_player,
                               status: "dropped")
      insert(:roster_position, fantasy_team: team,
                               fantasy_player: ir_player,
                               status: "injured_reserve")

      team = Store.find(team.id)

      assert %{team_name: "Brown"} = team
      assert Enum.count(team.roster_positions) == 21
    end
  end

  describe "find_for_update" do
    test "gets a team for the edit form" do
      team = insert(:fantasy_team, team_name: "Brown")
      insert(:filled_roster_position, fantasy_team: team)

      result = Store.find_for_update(team.id)

      assert result.team_name == team.team_name
      assert Enum.count(result.roster_positions) == 1
    end
  end
end
