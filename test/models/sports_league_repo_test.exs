defmodule Ex338.SportsLeagueRepoTest do
  use Ex338.ModelCase
  alias Ex338.SportsLeague

  describe "alphabetical/1" do
    test "returns sports leagues in alphabetical order" do
      insert(:sports_league, league_name: "a")
      insert(:sports_league, league_name: "b")
      insert(:sports_league, league_name: "c")

      query = SportsLeague |> SportsLeague.alphabetical
      query = from s in query, select: s.league_name

      assert Repo.all(query) == ~w(a b c)
    end
  end
end
