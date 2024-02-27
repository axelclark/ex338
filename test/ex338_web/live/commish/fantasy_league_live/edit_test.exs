defmodule Ex338Web.Commish.FantasyLeagueLiveTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

  alias Ex338.Accounts.User

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
             |> render_change() =~ "can&#39;t be blank<"

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

      assert Flash.get(conn.assigns.flash, :error) == "You are not authorized"
    end
  end
end
