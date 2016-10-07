defmodule Ex338.RosterPositionRepoTest do
  use Ex338.ModelCase
  alias Ex338.{RosterPosition}

  describe "active_positions/1" do
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

  describe "update_dropped_player/5" do
    test "updates roster position by team and player ids" do
      team   = insert(:fantasy_team)
      player = insert(:fantasy_player)
      position = insert(:roster_position, fantasy_player: player,
                                          fantasy_team:   team,
                                          status:         "active",
                                          released_at:    nil)
      released_at = Ecto.DateTime.utc
      status = "dropped"

      RosterPosition
      |> RosterPosition.update_position_status(team.id, player.id, released_at,
                                               status)
      |> Repo.update_all([])

      result = Repo.get!(RosterPosition, position.id)

      assert result.status == "dropped"
      assert result.released_at == Ecto.DateTime.utc
    end
  end
end
