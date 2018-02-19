defmodule Ex338.SportsLeagueRepoTest do
  use Ex338.DataCase
  alias Ex338.SportsLeague

  describe "abbrev_a_to_z/1" do
    test "sorts abbrev a to z" do
      insert(:sports_league, league_name: "a", abbrev: "g")
      insert(:sports_league, league_name: "c", abbrev: "f")
      insert(:sports_league, league_name: "b", abbrev: "e")

      result =
        SportsLeague
        |> SportsLeague.abbrev_a_to_z()
        |> SportsLeague.select_abbrev()
        |> Repo.all()

      assert result == ~w(e f g)
    end
  end

  describe "alphabetical/1" do
    test "returns sports leagues in alphabetical order" do
      insert(:sports_league, league_name: "a")
      insert(:sports_league, league_name: "b")
      insert(:sports_league, league_name: "c")

      result =
        SportsLeague
        |> SportsLeague.alphabetical()
        |> Repo.all()

      assert Enum.map(result, & &1.league_name) == ~w(a b c)
    end
  end

  describe "for_league/2" do
    test "returns sports for a fantasy league" do
      league_a = insert(:fantasy_league)
      league_b = insert(:fantasy_league)

      sport_a = insert(:sports_league)
      sport_b = insert(:sports_league)
      sport_c = insert(:sports_league)

      insert(:league_sport, fantasy_league: league_a, sports_league: sport_a)
      insert(:league_sport, fantasy_league: league_a, sports_league: sport_c)
      insert(:league_sport, fantasy_league: league_b, sports_league: sport_b)
      insert(:league_sport, fantasy_league: league_b, sports_league: sport_c)

      result =
        SportsLeague
        |> SportsLeague.for_league(league_a.id)
        |> Repo.all()

      assert Enum.any?(result, &(&1.id == sport_a.id))
      assert Enum.any?(result, &(&1.id == sport_c.id))
    end
  end

  describe "preload_league_overall_championships/2" do
    test "return overall championships for a fantasy league" do
      league_a = insert(:fantasy_league, year: 2018)
      sport_a = insert(:sports_league)
      insert(:league_sport, fantasy_league: league_a, sports_league: sport_a)

      champ = insert(:championship, sports_league: sport_a, category: "overall", year: 2018)
      insert(:championship, sports_league: sport_a, category: "event", year: 2018)
      insert(:championship, sports_league: sport_a, category: "overall", year: 2017)

      %{championships: [result]} =
        SportsLeague
        |> SportsLeague.preload_league_overall_championships(league_a.id)
        |> Repo.one()

      assert champ.id == result.id
    end
  end

  describe "select_abbrev/1" do
    test "selects abbrev field" do
      sport = insert(:sports_league, league_name: "a", abbrev: "g")

      result =
        SportsLeague
        |> SportsLeague.select_abbrev()
        |> Repo.one()

      assert result == sport.abbrev
    end
  end
end
