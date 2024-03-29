defmodule Ex338Web.ChampionshipLive.IndexTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

  describe "index/2" do
    test "lists all championships", %{conn: conn} do
      f_league = insert(:fantasy_league, year: 2017)
      s_league_a = insert(:sports_league)
      s_league_b = insert(:sports_league)
      insert(:league_sport, fantasy_league: f_league, sports_league: s_league_a)
      insert(:league_sport, fantasy_league: f_league, sports_league: s_league_b)
      championship_a = insert(:championship, sports_league: s_league_a)
      championship_b = insert(:championship, sports_league: s_league_b)

      {:ok, _view, html} = live(conn, ~p"/fantasy_leagues/#{f_league.id}/championships")

      assert html =~ "Championships"
      assert html =~ championship_a.title
      assert html =~ championship_b.title
      assert html =~ championship_b.sports_league.abbrev
    end
  end
end
