defmodule Ex338Web.InjuredReserveAdminControllerTest do
  use Ex338Web.ConnCase
  alias Ex338.{Accounts.User, InjuredReserves.InjuredReserve}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "update/2" do
    test "processes an approved IR claim", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team, fantasy_player: player_a)

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b,
          status: "submitted"
        )

      conn =
        patch(
          conn,
          fantasy_league_injured_reserve_admin_path(conn, :update, league.id, ir.id, %{
            "status" => "approved"
          })
        )

      assert redirected_to(conn) ==
               fantasy_league_injured_reserve_path(
                 conn,
                 :index,
                 team.fantasy_league_id
               )

      assert Repo.get!(InjuredReserve, ir.id).status == "approved"
    end

    test "returns errror if position is missing", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      ir =
        insert(
          :injured_reserve,
          injured_player: player_a,
          fantasy_team: team,
          replacement_player: player_b,
          status: "submitted"
        )

      conn =
        patch(
          conn,
          fantasy_league_injured_reserve_admin_path(conn, :update, league.id, ir.id, %{
            "status" => "approved"
          })
        )

      assert redirected_to(conn) ==
               fantasy_league_injured_reserve_path(
                 conn,
                 :index,
                 team.fantasy_league_id
               )

      assert get_flash(conn, :error) == "\"RosterPosition for IR not found\""
    end

    test "redirects to root if user is not admin", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      ir = insert(:injured_reserve, fantasy_team: team)

      conn =
        patch(
          conn,
          fantasy_league_injured_reserve_admin_path(
            conn,
            :update,
            league.id,
            ir.id,
            %{}
          )
        )

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
