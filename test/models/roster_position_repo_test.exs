defmodule Ex338.RosterPositionRepoTest do
  use Ex338.ModelCase
  alias Ex338.{RosterPosition}

  describe "active_positions/1" do
    test "only returns active roster positions with championship results" do
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
      championship = insert(:championship, category: "overall")
      insert(:championship_result, fantasy_player: player_a,
                                   championship: championship)

      results = RosterPosition
                |> RosterPosition.active_positions
                |> Repo.all
      result  = List.first(results)

      assert Enum.count(results) == 1
      assert Enum.count(result.fantasy_player.championship_results) == 1
    end
  end

  describe "current_positions/1" do
    test "returns active & ir roster positions with championship results" do
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      player_c = insert(:fantasy_player)
      team = insert(:fantasy_team)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a,
                               status: "injured_reserve")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_b,
                               status: "active")
      insert(:roster_position, fantasy_team: team, fantasy_player: player_c,
                               status: "traded")
      championship = insert(:championship, category: "overall")
      insert(:championship_result, fantasy_player: player_a,
                                   championship: championship)

      results = RosterPosition
                |> RosterPosition.current_positions
                |> Repo.all
      result  = List.first(results)

      assert Enum.count(results) == 2
      assert Enum.count(result.fantasy_player.championship_results) == 1
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

  describe "count_positions_for_team" do
    test "counts the active positions on a fantasy team" do
      team = insert(:fantasy_team)
      insert_list(2, :roster_position, fantasy_team: team, status: "active")

      count = RosterPosition |> RosterPosition.count_positions_for_team(team.id)

      assert count == 2
    end
  end
end
