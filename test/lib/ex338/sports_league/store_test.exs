defmodule Ex338.SportsLeague.StoreTest do
  use Ex338.ModelCase
  alias Ex338.SportsLeague.Store

  describe "league_abbrevs/1" do
    test "returns sports abbrevs in order" do
      sport_b = insert(:sports_league, abbrev: "b")
      sport_c = insert(:sports_league, abbrev: "c")
      sport_a = insert(:sports_league, abbrev: "a")
      insert(:sports_league, abbrev: "z")

      league = insert(:fantasy_league)

      insert(:league_sport, fantasy_league: league, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league, sports_league: sport_b)
      insert(:league_sport, fantasy_league: league, sports_league: sport_c)

      result = Store.league_abbrevs(league.id)

      assert result == ~w(a b c)
    end
  end
end

