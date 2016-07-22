defmodule Ex338.FantasyTeamRepoTest do
  use Ex338.ModelCase
  alias Ex338.FantasyTeam

  describe "alphabetical/1" do
    test "returns fantasy teams in alphabetical order" do
      league = insert(:fantasy_league)
      insert(:fantasy_team, team_name: "a", fantasy_league: league)
      insert(:fantasy_team, team_name: "b", fantasy_league: league)
      insert(:fantasy_team, team_name: "c", fantasy_league: league)

      query = FantasyTeam |> FantasyTeam.alphabetical
      query = from f in query, select: f.team_name

      assert Repo.all(query) == ~w(a b c)
    end
  end
end
