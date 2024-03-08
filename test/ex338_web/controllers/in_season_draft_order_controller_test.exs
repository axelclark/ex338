defmodule Ex338Web.InSeasonDraftOrderControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.InSeasonDraftPicks.InSeasonDraftPick

  describe "create/2 as admin" do
    setup :register_and_log_in_admin

    test "admin creates draft picks for a championship", %{conn: conn} do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      championship = insert(:championship, category: "overall", sports_league: sport)

      player_1 =
        insert(:fantasy_player, player_name: "KD Pick #1", sports_league: sport, draft_pick: true)

      player_2 =
        insert(:fantasy_player, player_name: "KD Pick #2", sports_league: sport, draft_pick: true)

      player_3 =
        insert(:fantasy_player, player_name: "KD Pick #3", sports_league: sport, draft_pick: true)

      insert(:roster_position, fantasy_player: player_1, fantasy_team: team_a)
      insert(:roster_position, fantasy_player: player_2, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_3, fantasy_team: team_a)

      attrs = %{championship_id: championship.id}

      conn =
        post(conn, ~p"/fantasy_leagues/#{league.id}/in_season_draft_order", attrs)

      results = Repo.all(InSeasonDraftPick)

      assert Enum.count(results) == 3

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{league.id}/championships/#{championship.id}"
    end

    test "handles error", %{conn: conn} do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      team_b = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      championship = insert(:championship, category: "overall", sports_league: sport)

      player_1 =
        insert(:fantasy_player, player_name: "Wrong Name", sports_league: sport, draft_pick: true)

      player_2 =
        insert(:fantasy_player, player_name: "KD Pick #2", sports_league: sport, draft_pick: true)

      player_3 =
        insert(:fantasy_player, player_name: "KD Pick #3", sports_league: sport, draft_pick: true)

      insert(:roster_position, fantasy_player: player_1, fantasy_team: team_a)
      insert(:roster_position, fantasy_player: player_2, fantasy_team: team_b)
      insert(:roster_position, fantasy_player: player_3, fantasy_team: team_a)

      attrs = %{championship_id: championship.id}

      conn =
        post(conn, ~p"/fantasy_leagues/#{league.id}/in_season_draft_order", attrs)

      results = Repo.all(InSeasonDraftPick)

      assert Enum.count(results) == 0

      assert redirected_to(conn) ==
               ~p"/fantasy_leagues/#{league.id}/championships/#{championship.id}"
    end
  end

  describe "create/2 as user" do
    setup :register_and_log_in_user

    test "redirects to root if user is not admin", %{conn: conn} do
      league = insert(:fantasy_league)
      championship = insert(:championship, category: "overall")
      attrs = %{championship_id: championship.id}

      conn =
        post(conn, ~p"/fantasy_leagues/#{league.id}/in_season_draft_order", attrs)

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
