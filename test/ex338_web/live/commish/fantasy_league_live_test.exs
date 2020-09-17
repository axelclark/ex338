defmodule Ex338Web.Commish.FantasyLeagueLiveTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

  alias Ex338.FantasyLeagues

  @create_attrs %{championships_end_at: "2010-04-17T14:00:00Z", championships_start_at: "2010-04-17T14:00:00Z", division: "some division", draft_method: "some draft_method", fantasy_league_name: "some fantasy_league_name", max_draft_hours: 42, max_flex_spots: 42, must_draft_each_sport?: true, navbar_display: "some navbar_display", only_flex?: true, year: 42}
  @update_attrs %{championships_end_at: "2011-05-18T15:01:01Z", championships_start_at: "2011-05-18T15:01:01Z", division: "some updated division", draft_method: "some updated draft_method", fantasy_league_name: "some updated fantasy_league_name", max_draft_hours: 43, max_flex_spots: 43, must_draft_each_sport?: false, navbar_display: "some updated navbar_display", only_flex?: false, year: 43}
  @invalid_attrs %{championships_end_at: nil, championships_start_at: nil, division: nil, draft_method: nil, fantasy_league_name: nil, max_draft_hours: nil, max_flex_spots: nil, must_draft_each_sport?: nil, navbar_display: nil, only_flex?: nil, year: nil}

  defp fixture(:fantasy_league) do
    {:ok, fantasy_league} = FantasyLeagues.create_fantasy_league(@create_attrs)
    fantasy_league
  end

  defp create_fantasy_league(_) do
    fantasy_league = fixture(:fantasy_league)
    %{fantasy_league: fantasy_league}
  end

  describe "Index" do
    setup [:create_fantasy_league]

    test "lists all fantasy_leagues", %{conn: conn, fantasy_league: fantasy_league} do
      {:ok, _index_live, html} = live(conn, Routes.commish_fantasy_league_index_path(conn, :index))

      assert html =~ "Listing Fantasy leagues"
      assert html =~ fantasy_league.division
    end

    test "saves new fantasy_league", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.commish_fantasy_league_index_path(conn, :index))

      assert index_live |> element("a", "New Fantasy league") |> render_click() =~
               "New Fantasy league"

      assert_patch(index_live, Routes.commish_fantasy_league_index_path(conn, :new))

      assert index_live
             |> form("#fantasy_league-form", fantasy_league: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#fantasy_league-form", fantasy_league: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.commish_fantasy_league_index_path(conn, :index))

      assert html =~ "Fantasy league created successfully"
      assert html =~ "some division"
    end

    test "updates fantasy_league in listing", %{conn: conn, fantasy_league: fantasy_league} do
      {:ok, index_live, _html} = live(conn, Routes.commish_fantasy_league_index_path(conn, :index))

      assert index_live |> element("#fantasy_league-#{fantasy_league.id} a", "Edit") |> render_click() =~
               "Edit Fantasy league"

      assert_patch(index_live, Routes.commish_fantasy_league_index_path(conn, :edit, fantasy_league))

      assert index_live
             |> form("#fantasy_league-form", fantasy_league: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#fantasy_league-form", fantasy_league: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.commish_fantasy_league_index_path(conn, :index))

      assert html =~ "Fantasy league updated successfully"
      assert html =~ "some updated division"
    end

    test "deletes fantasy_league in listing", %{conn: conn, fantasy_league: fantasy_league} do
      {:ok, index_live, _html} = live(conn, Routes.commish_fantasy_league_index_path(conn, :index))

      assert index_live |> element("#fantasy_league-#{fantasy_league.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#fantasy_league-#{fantasy_league.id}")
    end
  end

  describe "Show" do
    setup [:create_fantasy_league]

    test "displays fantasy_league", %{conn: conn, fantasy_league: fantasy_league} do
      {:ok, _show_live, html} = live(conn, Routes.commish_fantasy_league_show_path(conn, :show, fantasy_league))

      assert html =~ "Show Fantasy league"
      assert html =~ fantasy_league.division
    end

    test "updates fantasy_league within modal", %{conn: conn, fantasy_league: fantasy_league} do
      {:ok, show_live, _html} = live(conn, Routes.commish_fantasy_league_show_path(conn, :show, fantasy_league))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Fantasy league"

      assert_patch(show_live, Routes.commish_fantasy_league_show_path(conn, :edit, fantasy_league))

      assert show_live
             |> form("#fantasy_league-form", fantasy_league: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#fantasy_league-form", fantasy_league: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.commish_fantasy_league_show_path(conn, :show, fantasy_league))

      assert html =~ "Fantasy league updated successfully"
      assert html =~ "some updated division"
    end
  end
end
