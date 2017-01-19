defmodule Ex338.ChampionshipSlotRepoTest do
  use Ex338.ModelCase

  alias Ex338.{ChampionshipSlot}

  describe "preload_assocs_by_league/2" do
    test "preloads all assocs for a league" do
      player_a = insert(:fantasy_player)
      f_league_a = insert(:fantasy_league)
      f_league_b = insert(:fantasy_league)
      championship = insert(:championship)
      team_a = insert(:fantasy_team, fantasy_league: f_league_a)
      team_b = insert(:fantasy_team, fantasy_league: f_league_b)
      pos = insert(:roster_position, fantasy_team: team_a,
                                     fantasy_player: player_a)
      other_pos = insert(:roster_position, fantasy_team: team_b,
                                            fantasy_player: player_a)
      insert(:championship_slot, championship: championship,
                                 roster_position: pos)
      insert(:championship_slot, championship: championship,
                                 roster_position: other_pos)

      [result] =
        ChampionshipSlot
        |> ChampionshipSlot.preload_assocs_by_league(f_league_a.id)
        |> Repo.all

      assert result.roster_position.id == pos.id
      assert result.roster_position.fantasy_team.id == team_a.id
      assert result.roster_position.fantasy_player.id == player_a.id
    end
  end
end
