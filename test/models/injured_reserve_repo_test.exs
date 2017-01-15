defmodule Ex338.InjuredReserveRepoTest do
  use Ex338.ModelCase, async: false

  alias Ex338.{InjuredReserve}

  describe "get_all_actions/1" do
    test "returns all waivers with assocs in a league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      other_team = insert(:fantasy_team, fantasy_league: other_league)
      insert_list(2, :add_replace_injured_reserve, fantasy_team: team)
      insert(:add_replace_injured_reserve, fantasy_team: other_team)

      result = InjuredReserve.get_all_actions(InjuredReserve, league.id)

      assert Enum.count(result) == 2
    end
  end

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
end
