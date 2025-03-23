defmodule Ex338Web.Commish.FantasyLeagueLiveTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

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

  describe "Edit as admin" do
    setup :register_and_log_in_admin

    test "updates fantasy_league", %{conn: conn} do
      fantasy_league = insert(:fantasy_league)

      {:ok, edit_live, _html} =
        live(conn, Routes.commish_fantasy_league_edit_path(conn, :edit, fantasy_league))

      assert edit_live
             |> form("#fantasy_league-form", fantasy_league: @invalid_attrs)
             |> render_change() =~ "can't be blank"

      {:ok, _, html} =
        edit_live
        |> form("#fantasy_league-form", fantasy_league: @update_attrs)
        |> render_submit()
        |> follow_redirect(
          conn,
          Routes.commish_fantasy_league_edit_path(conn, :edit, fantasy_league)
        )

      assert html =~ "Fantasy league updated successfully"
      assert html =~ "some updated division"
    end
  end

  describe "Edit as user" do
    setup :register_and_log_in_user

    test "redirects if not admin", %{conn: conn} do
      fantasy_league = insert(:fantasy_league)

      {:ok, conn} =
        conn
        |> live(Routes.commish_fantasy_league_edit_path(conn, :edit, fantasy_league))
        |> follow_redirect(conn, "/")

      assert Flash.get(conn.assigns.flash, :error) == "You are not authorized"
    end
  end
end
