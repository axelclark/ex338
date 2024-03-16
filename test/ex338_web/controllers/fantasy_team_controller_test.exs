defmodule Ex338Web.FantasyTeamControllerTest do
  use Ex338Web.ConnCase

  describe "index/2" do
    test "lists all fantasy teams in a fantasy league", %{conn: conn} do
      league = insert(:fantasy_league)
      teams = insert_list(2, :fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      insert(:championship, sports_league: sport)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:fantasy_player, sports_league: sport)

      ir_player = insert(:fantasy_player, sports_league: sport)

      insert(
        :roster_position,
        fantasy_team: hd(teams),
        fantasy_player: ir_player,
        status: "injured_reserve"
      )

      conn = get(conn, ~p"/fantasy_leagues/#{league.id}/fantasy_teams")

      assert html_response(conn, 200) =~ ~r/Fantasy Teams/
    end

    test "shows fantasy team championship with events results", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      user = insert(:user)
      insert(:owner, user: user, fantasy_team: team)

      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position, fantasy_team: team, fantasy_player: player)
      insert(:champ_with_events_result, fantasy_team: team, points: 8, championship: championship)

      conn = get(conn, ~p"/fantasy_leagues/#{league.id}/fantasy_teams")

      assert html_response(conn, 200) =~ ~r/Brown/
      assert String.contains?(conn.resp_body, championship.title)
      assert String.contains?(conn.resp_body, "8")
    end

    test "shows fantasy team slot results", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)

      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)
      championship2 = insert(:championship, sports_league: sport)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)

      pos = insert(:roster_position, fantasy_team: team, fantasy_player: player)

      _slot1 =
        insert(
          :championship_slot,
          roster_position: pos,
          championship: championship,
          slot: 1
        )

      _slot2 =
        insert(
          :championship_slot,
          roster_position: pos,
          championship: championship2,
          slot: 1
        )

      _champ_result1 =
        insert(
          :championship_result,
          championship: championship,
          fantasy_player: player,
          points: 8,
          rank: 1
        )

      _champ_result2 =
        insert(
          :championship_result,
          championship: championship2,
          fantasy_player: player,
          points: 5,
          rank: 2
        )

      conn = get(conn, ~p"/fantasy_leagues/#{league.id}/fantasy_teams")

      assert html_response(conn, 200) =~ ~r/Slot/
      assert String.contains?(conn.resp_body, championship.sports_league.abbrev)
      assert String.contains?(conn.resp_body, "13")
    end
  end
end
