defmodule Ex338.FantasyTeamRepoTest do
  use Ex338.ModelCase
  alias Ex338.FantasyTeam

  describe "by_league/2" do
    test "returns fantasy teams in a fantasy league" do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      _team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      _other_team = insert(:fantasy_team, team_name: "Another Team", 
                                         fantasy_league: other_league)

      query = FantasyTeam |> FantasyTeam.by_league(league.id)
      query = from f in query, select: f.team_name

      assert Repo.all(query) == ~w(Brown)
    end
  end
end
