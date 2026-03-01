defmodule Ex338Web.Api.V1.DraftPickControllerTest do
  use Ex338Web.ConnCase

  describe "GET /api/v1/fantasy_leagues/:fantasy_league_id/draft_picks" do
    test "returns draft picks for a league", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, waiver_position: 1)
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)

      insert(:draft_pick,
        fantasy_league: league,
        fantasy_team: team,
        fantasy_player: player,
        draft_position: 1.01
      )

      conn = get(conn, ~p"/api/v1/fantasy_leagues/#{league.id}/draft_picks")

      assert %{"draft_picks" => picks} = json_response(conn, 200)
      assert length(picks) == 1
      [pick] = picks
      assert pick["draft_position"]
      assert pick["fantasy_team"]["team_name"]
      assert pick["fantasy_player"]["player_name"]
    end
  end
end
