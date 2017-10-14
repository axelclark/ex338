defmodule Ex338Web.FantasyPlayerControllerTest do
  use Ex338Web.ConnCase

  setup %{conn: conn} do
    user = %Ex338.User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all owned/unowned fantasy players in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      team_b = insert(:fantasy_team, team_name: "Axel", fantasy_league: league)
      other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)

      sport = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sport)
      insert(:league_sport, fantasy_league: other_league, sports_league: sport)

      player = insert(:fantasy_player, sports_league: sport)
      ir_player = insert(:fantasy_player, sports_league: sport)
      unowned_player = insert(:fantasy_player, sports_league: sport)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player,
                               status: "active")
      insert(:roster_position, fantasy_team: other_team, fantasy_player: player,
                               status: "active")
      insert(:roster_position, fantasy_team: team_b, fantasy_player: ir_player,
                               status: "injured_reserve")

      conn = get conn, fantasy_league_fantasy_player_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Fantasy Players/
      assert String.contains?(conn.resp_body, player.player_name)
      assert String.contains?(conn.resp_body, unowned_player.player_name)
      assert String.contains?(conn.resp_body, ir_player.player_name)
      assert String.contains?(conn.resp_body, team_a.team_name)
      assert String.contains?(conn.resp_body, team_b.team_name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end
end
