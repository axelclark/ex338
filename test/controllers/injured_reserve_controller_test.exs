defmodule Ex338.InjuredReserveControllerTest do
  use Ex338.ConnCase
  alias Ex338.{User}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "index/2" do
    test "lists all injured reserve transactions in a league", %{conn: conn} do
      league = insert(:fantasy_league)
      other_league = insert(:fantasy_league)
      team = insert(:fantasy_team, team_name: "Brown", fantasy_league: league)
      player = insert(:fantasy_player)
      other_team = insert(:fantasy_team, team_name: "Another Team",
                                         fantasy_league: other_league)
      insert(:add_replace_injured_reserve, fantasy_team: team,
                                           add_player: player,
                                           status: "approved")
      insert(:add_replace_injured_reserve, fantasy_team: other_team,
                                           add_player: player,
                                           status: "approved")

      conn = get conn, fantasy_league_injured_reserve_path(conn, :index, league.id)

      assert html_response(conn, 200) =~ ~r/Injured Reserve Actions/
      assert String.contains?(conn.resp_body, team.team_name)
      assert String.contains?(conn.resp_body, player.player_name)
      refute String.contains?(conn.resp_body, other_team.team_name)
    end
  end
end
