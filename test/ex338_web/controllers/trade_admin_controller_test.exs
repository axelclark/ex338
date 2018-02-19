defmodule Ex338Web.TradeAdminControllerTest do
  use Ex338Web.ConnCase
  alias Ex338.{Trade, Repo, User}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "update/2" do
    test "processes an approved trade", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      trade = insert(:trade, status: "Pending")

      insert(
        :trade_line_item,
        gaining_team: team_b,
        losing_team: team_a,
        fantasy_player: player_a,
        trade: trade
      )

      insert(
        :trade_line_item,
        gaining_team: team_a,
        losing_team: team_b,
        fantasy_player: player_b,
        trade: trade
      )

      params = %{"status" => "Approved"}

      conn =
        patch(
          conn,
          fantasy_league_trade_admin_path(
            conn,
            :update,
            league.id,
            trade.id,
            params
          )
        )

      assert redirected_to(conn) ==
               fantasy_league_trade_path(conn, :index, team_a.fantasy_league_id)

      assert Repo.get!(Trade, trade.id).status == "Approved"
    end

    test "returns errror if position is missing", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b, status: "dropped")

      trade = insert(:trade, status: "Pending")

      insert(
        :trade_line_item,
        gaining_team: team_b,
        losing_team: team_a,
        fantasy_player: player_a,
        trade: trade
      )

      insert(
        :trade_line_item,
        gaining_team: team_a,
        losing_team: team_b,
        fantasy_player: player_b,
        trade: trade
      )

      params = %{"status" => "Approved"}

      conn =
        patch(
          conn,
          fantasy_league_trade_admin_path(
            conn,
            :update,
            league.id,
            trade.id,
            params
          )
        )

      assert redirected_to(conn) ==
               fantasy_league_trade_path(conn, :index, team_a.fantasy_league_id)

      assert get_flash(conn, :error) == "\"One or more positions not found\""
      assert Repo.get!(Trade, trade.id).status == "Pending"
    end

    test "redirects to root if user is not admin", %{conn: conn} do
      league = insert(:fantasy_league)
      trade = insert(:trade, status: "Pending")
      params = %{}

      conn =
        patch(
          conn,
          fantasy_league_trade_admin_path(
            conn,
            :update,
            league.id,
            trade.id,
            trade: params
          )
        )

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
