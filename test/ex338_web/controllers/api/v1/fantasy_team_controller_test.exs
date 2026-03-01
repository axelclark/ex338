defmodule Ex338Web.Api.V1.FantasyTeamControllerTest do
  use Ex338Web.ConnCase

  describe "GET /api/v1/fantasy_teams/:id" do
    test "returns team with roster and owners", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, waiver_position: 1)
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      player = insert(:fantasy_player, sports_league: sport)

      insert(:roster_position,
        fantasy_team: team,
        fantasy_player: player,
        status: "active"
      )

      conn = get(conn, ~p"/api/v1/fantasy_teams/#{team.id}")

      assert %{"fantasy_team" => data} = json_response(conn, 200)
      assert data["id"] == team.id
      assert data["team_name"] == team.team_name
      assert is_list(data["owners"])
      assert is_list(data["roster_positions"])
      assert data["fantasy_league"]["id"] == league.id
    end
  end
end
