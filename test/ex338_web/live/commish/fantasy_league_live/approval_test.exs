defmodule Ex338Web.Commish.FantasyLeagueLive.ApprovalTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

  alias Ex338.Accounts.User

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "Approvals" do
    test "lists injured reserves and process approval", %{conn: conn} do
      insert(:user, name: "test", email: "test@example.com", id: 1)
      conn = put_in(conn.assigns.current_user.admin, true)
      fantasy_league = insert(:fantasy_league)
      fantasy_team = insert(:fantasy_team, fantasy_league: fantasy_league)
      injured_player = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: fantasy_team, fantasy_player: injured_player)
      replacement = insert(:fantasy_player)

      injured_reserve =
        insert(:injured_reserve,
          fantasy_team: fantasy_team,
          injured_player: injured_player,
          replacement_player: replacement,
          status: :submitted
        )

      {:ok, view, html} =
        live(conn, commish_fantasy_league_approval_path(conn, :index, fantasy_league.id))

      assert html =~ fantasy_team.team_name
      assert html =~ injured_player.player_name

      assert view
             |> element("#approve-injured-reserve-#{injured_reserve.id}")
             |> render_click() =~ "IR successfully processed"

      assert view
             |> element("#return-injured-reserve-#{injured_reserve.id}")
             |> render_click() =~ "None for review"
    end

    test "lists injured reserves and handles IR error", %{conn: conn} do
      insert(:user, name: "test", email: "test@example.com", id: 1)
      conn = put_in(conn.assigns.current_user.admin, true)
      fantasy_league = insert(:fantasy_league)
      fantasy_team = insert(:fantasy_team, fantasy_league: fantasy_league)
      injured_player = insert(:fantasy_player)
      replacement = insert(:fantasy_player)

      injured_reserve =
        insert(:injured_reserve,
          fantasy_team: fantasy_team,
          injured_player: injured_player,
          replacement_player: replacement,
          status: :submitted
        )

      {:ok, view, _html} =
        live(conn, commish_fantasy_league_approval_path(conn, :index, fantasy_league.id))

      assert view
             |> element("#approve-injured-reserve-#{injured_reserve.id}")
             |> render_click() =~ "No roster position found for IR."
    end

    test "lists trades and processes an approved trade", %{conn: conn} do
      insert(:user, name: "test", email: "test@example.com", id: 1)
      conn = put_in(conn.assigns.current_user.admin, true)
      fantasy_league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: fantasy_league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: fantasy_league)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      trade = insert(:trade, status: "Pending", submitted_by_team: team_a)

      future_pick_a = insert(:future_pick, current_team: team_a)
      future_pick_b = insert(:future_pick, current_team: team_b)

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

      insert(
        :trade_line_item,
        gaining_team: team_b,
        losing_team: team_a,
        future_pick: future_pick_a,
        trade: trade
      )

      insert(
        :trade_line_item,
        gaining_team: team_a,
        losing_team: team_b,
        future_pick: future_pick_b,
        trade: trade
      )

      {:ok, view, html} =
        live(conn, commish_fantasy_league_approval_path(conn, :index, fantasy_league.id))

      assert html =~ team_a.team_name
      assert html =~ player_a.player_name

      assert view
             |> element("#approve-trade-#{trade.id}")
             |> render_click() =~ "Trade successfully processed"
    end

    test "lists trades and processes a disapproved trade", %{conn: conn} do
      insert(:user, name: "test", email: "test@example.com", id: 1)
      conn = put_in(conn.assigns.current_user.admin, true)
      fantasy_league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: fantasy_league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: fantasy_league)
      player_b = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      trade = insert(:trade, status: "Pending", submitted_by_team: team_a)

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

      {:ok, view, html} =
        live(conn, commish_fantasy_league_approval_path(conn, :index, fantasy_league.id))

      assert html =~ team_a.team_name
      assert html =~ player_a.player_name

      assert view
             |> element("#disapprove-trade-#{trade.id}")
             |> render_click() =~ "Trade successfully processed"
    end

    test "lists trades and returns error if position is missting", %{conn: conn} do
      insert(:user, name: "test", email: "test@example.com", id: 1)
      conn = put_in(conn.assigns.current_user.admin, true)
      fantasy_league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: fantasy_league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      team_b = insert(:fantasy_team, fantasy_league: fantasy_league)
      player_b = insert(:fantasy_player)
      insert(:roster_position, status: "dropped", fantasy_team: team_b, fantasy_player: player_b)

      trade = insert(:trade, status: "Pending", submitted_by_team: team_a)

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

      {:ok, view, _html} =
        live(conn, commish_fantasy_league_approval_path(conn, :index, fantasy_league.id))

      assert view
             |> element("#approve-trade-#{trade.id}")
             |> render_click() =~ "One or more positions not found"
    end

    test "toggles showing league actions and all actions", %{conn: conn} do
      insert(:user, name: "test", email: "test@example.com", id: 1)
      conn = put_in(conn.assigns.current_user.admin, true)

      empty_league = insert(:fantasy_league)
      fantasy_league = insert(:fantasy_league)
      fantasy_team = insert(:fantasy_team, fantasy_league: fantasy_league)
      injured_player = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: fantasy_team, fantasy_player: injured_player)
      replacement = insert(:fantasy_player)

      insert(:injured_reserve,
        fantasy_team: fantasy_team,
        injured_player: injured_player,
        replacement_player: replacement,
        status: :submitted
      )

      team_b = insert(:fantasy_team, fantasy_league: fantasy_league)
      player_a = insert(:fantasy_player)
      player_b = insert(:fantasy_player)

      insert(:roster_position, fantasy_team: fantasy_team, fantasy_player: player_a)
      insert(:roster_position, fantasy_team: team_b, fantasy_player: player_b)

      trade = insert(:trade, status: "Pending", submitted_by_team: fantasy_team)

      insert(
        :trade_line_item,
        gaining_team: team_b,
        losing_team: fantasy_team,
        fantasy_player: player_a,
        trade: trade
      )

      insert(
        :trade_line_item,
        gaining_team: fantasy_team,
        losing_team: team_b,
        fantasy_player: player_b,
        trade: trade
      )

      {:ok, view, html} =
        live(conn, commish_fantasy_league_approval_path(conn, :index, empty_league.id))

      refute html =~ fantasy_team.team_name
      refute html =~ injured_player.player_name
      refute html =~ player_a.player_name

      html =
        view
        |> element("#toggle-league-approval-filter")
        |> render_click()

      assert html =~ fantasy_team.team_name
      assert html =~ injured_player.player_name
      assert html =~ player_a.player_name

      html =
        view
        |> element("#toggle-league-approval-filter")
        |> render_click()

      refute html =~ fantasy_team.team_name
      refute html =~ injured_player.player_name
      refute html =~ player_a.player_name
    end

    test "allows commish to create future picks if none have been created", %{conn: conn} do
      insert(:user, name: "test", email: "test@example.com", id: 1)
      conn = put_in(conn.assigns.current_user.admin, true)
      fantasy_league = insert(:fantasy_league)

      team_a = insert(:fantasy_team, fantasy_league: fantasy_league)
      player_a = insert(:fantasy_player)
      insert(:roster_position, fantasy_team: team_a, fantasy_player: player_a)

      {:ok, view, _html} =
        live(conn, commish_fantasy_league_approval_path(conn, :index, fantasy_league.id))

      assert has_element?(view, "h2", "Future Picks")

      view
      |> element("button#create-future-picks")
      |> render_click()

      assert has_element?(view, "span", "20 future picks")
      refute has_element?(view, "button#create-future-picks")
    end

    test "redirects if not admin", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, false)
      fantasy_league = insert(:fantasy_league)

      {:ok, conn} =
        conn
        |> live(commish_fantasy_league_approval_path(conn, :index, fantasy_league))
        |> follow_redirect(conn, "/")

      assert Flash.get(conn.assigns.flash, :error) == "You are not authorized"
    end
  end
end
