defmodule Ex338.InjuredReserveRepoTest do
  use Ex338.DataCase, async: false

  alias Ex338.{InjuredReserve}

  describe "by_league/2" do
    test "returns injured reserve actions in a fantasy league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert(:add_replace_injured_reserve, fantasy_team: team)
      insert(:add_replace_injured_reserve, fantasy_team: other_team)

      query = InjuredReserve.by_league(InjuredReserve, league.id)
      query = from i in query, select: i.fantasy_team_id

      assert Repo.all(query) == [team.id]
    end
  end

  describe "preload_assocs/1" do
    test "returns the user with assocs for a given id" do
      team = insert(:fantasy_team)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      ir = insert(:injured_reserve, add_player: player_a, fantasy_team: team,
        replacement_player: player_b)

      result =
        InjuredReserve
        |> InjuredReserve.preload_assocs
        |> Repo.one

      assert result.id == ir.id
      assert result.add_player.id == player_a.id
      assert result.replacement_player.id == player_b.id
      assert result.fantasy_team.id == team.id
    end
  end
end
