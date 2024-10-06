defmodule Ex338Web.FantasyLeague.CalendarDownloadTest do
  use Ex338Web.ConnCase

  setup :register_and_log_in_user

  describe "get/2" do
    test "allows a user to download the calendar of events for a fantasy league", %{conn: conn} do
      fantasy_league = insert(:fantasy_league, year: 2017)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: fantasy_league, sports_league: sports_league)
      insert(:league_sport, fantasy_league: fantasy_league, sports_league: sports_league)
      championship = insert(:championship, sports_league: sports_league)

      _championship_event =
        insert(:championship,
          sports_league: sports_league,
          overall: championship,
          category: "event"
        )

      conn = get(conn, ~p"/fantasy_leagues/#{fantasy_league.id}/calendar_download")

      assert response_content_type(conn, :ics)
    end
  end
end
