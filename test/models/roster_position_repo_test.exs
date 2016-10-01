defmodule Ex338.RosterPositionRepoTest do
  use Ex338.ModelCase
  alias Ex338.{RosterPosition}

  describe "active_roster_positions/1" do
    test "only returns active roster positions" do
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      player_c = insert(:fantasy_player)
      team = insert(:fantasy_team)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a,
                               status: "active")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_b,
                               status: "dropped")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_c,
                               status: "traded")

      query = RosterPosition.active_positions(RosterPosition)

      assert Repo.aggregate(query, :count, :id) == 1
    end
  end
end
