defmodule Ex338Web.Commish.FantasyLeagueLiveTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

  alias Ex338.{Accounts.User}

  setup %{conn: conn} do
    user = %User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  @update_attrs %{
    division: "some updated division",
    draft_method: "keeper",
    fantasy_league_name: "some updated fantasy_league_name",
    max_draft_hours: 43,
    max_flex_spots: 43,
    must_draft_each_sport?: false,
    navbar_display: "hidden",
    only_flex?: false,
    year: 43
  }

  @invalid_attrs %{
    division: nil,
    draft_method: nil,
    fantasy_league_name: nil,
    max_draft_hours: nil,
    max_flex_spots: nil,
    navbar_display: nil,
    year: nil
  }

  describe "Edit" do
    test "updates fantasy_league", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, true)
      fantasy_league = insert(:fantasy_league)

      {:ok, edit_live, _html} =
        live(conn, commish_fantasy_league_edit_path(conn, :edit, fantasy_league))

      assert edit_live
             |> form("#fantasy_league-form", fantasy_league: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        edit_live
        |> form("#fantasy_league-form", fantasy_league: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, commish_fantasy_league_edit_path(conn, :edit, fantasy_league))

      assert html =~ "Fantasy league updated successfully"
      assert html =~ "some updated division"
    end

    test "redirects if not admin", %{conn: conn} do
      conn = put_in(conn.assigns.current_user.admin, false)
      fantasy_league = insert(:fantasy_league)

      {:ok, conn} =
        conn
        |> live(commish_fantasy_league_edit_path(conn, :edit, fantasy_league))
        |> follow_redirect(conn, "/")

      assert get_flash(conn, :error) == "You are not authorized"
    end
  end

  describe "Approvals" do
    test "lists actions for approval", %{conn: conn} do
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
  end
end
