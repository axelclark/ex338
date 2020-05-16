defmodule Ex338Web.PhxAdmin.FantasyTeamLiveTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

  alias Ex338.FantasyTeams

  @create_attrs %{autodraft_setting: "some autodraft_setting", avg_seconds_on_the_clock: 42, commish_notes: "some commish_notes", dues_paid: 120.5, max_flex_adj: 42, picks_selected: 42, team_name: "some team_name", total_draft_mins_adj: 42, total_seconds_on_the_clock: 42, waiver_position: 42, winnings_adj: 120.5, winnings_received: 120.5}
  @update_attrs %{autodraft_setting: "some updated autodraft_setting", avg_seconds_on_the_clock: 43, commish_notes: "some updated commish_notes", dues_paid: 456.7, max_flex_adj: 43, picks_selected: 43, team_name: "some updated team_name", total_draft_mins_adj: 43, total_seconds_on_the_clock: 43, waiver_position: 43, winnings_adj: 456.7, winnings_received: 456.7}
  @invalid_attrs %{autodraft_setting: nil, avg_seconds_on_the_clock: nil, commish_notes: nil, dues_paid: nil, max_flex_adj: nil, picks_selected: nil, team_name: nil, total_draft_mins_adj: nil, total_seconds_on_the_clock: nil, waiver_position: nil, winnings_adj: nil, winnings_received: nil}

  defp fixture(:fantasy_team) do
    {:ok, fantasy_team} = FantasyTeams.create_fantasy_team(@create_attrs)
    fantasy_team
  end

  defp create_fantasy_team(_) do
    fantasy_team = fixture(:fantasy_team)
    %{fantasy_team: fantasy_team}
  end

  describe "Index" do
    setup [:create_fantasy_team]

    test "lists all fantasy_teams", %{conn: conn, fantasy_team: fantasy_team} do
      {:ok, _index_live, html} = live(conn, Routes.phx_admin_fantasy_team_index_path(conn, :index))

      assert html =~ "Listing Fantasy teams"
      assert html =~ fantasy_team.autodraft_setting
    end

    test "saves new fantasy_team", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.phx_admin_fantasy_team_index_path(conn, :index))

      assert index_live |> element("a", "New Fantasy team") |> render_click() =~
        "New Fantasy team"

      assert_patch(index_live, Routes.phx_admin_fantasy_team_index_path(conn, :new))

      assert index_live
             |> form("#fantasy_team-form", fantasy_team: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#fantasy_team-form", fantasy_team: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.phx_admin_fantasy_team_index_path(conn, :index))

      assert html =~ "Fantasy team created successfully"
      assert html =~ "some autodraft_setting"
    end

    test "updates fantasy_team in listing", %{conn: conn, fantasy_team: fantasy_team} do
      {:ok, index_live, _html} = live(conn, Routes.phx_admin_fantasy_team_index_path(conn, :index))

      assert index_live |> element("#fantasy_team-#{fantasy_team.id} a", "Edit") |> render_click() =~
        "Edit Fantasy team"

      assert_patch(index_live, Routes.phx_admin_fantasy_team_index_path(conn, :edit, fantasy_team))

      assert index_live
             |> form("#fantasy_team-form", fantasy_team: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#fantasy_team-form", fantasy_team: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.phx_admin_fantasy_team_index_path(conn, :index))

      assert html =~ "Fantasy team updated successfully"
      assert html =~ "some updated autodraft_setting"
    end

    test "deletes fantasy_team in listing", %{conn: conn, fantasy_team: fantasy_team} do
      {:ok, index_live, _html} = live(conn, Routes.phx_admin_fantasy_team_index_path(conn, :index))

      assert index_live |> element("#fantasy_team-#{fantasy_team.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#fantasy_team-#{fantasy_team.id}")
    end
  end

  describe "Show" do
    setup [:create_fantasy_team]

    test "displays fantasy_team", %{conn: conn, fantasy_team: fantasy_team} do
      {:ok, _show_live, html} = live(conn, Routes.phx_admin_fantasy_team_show_path(conn, :show, fantasy_team))

      assert html =~ "Show Fantasy team"
      assert html =~ fantasy_team.autodraft_setting
    end

    test "updates fantasy_team within modal", %{conn: conn, fantasy_team: fantasy_team} do
      {:ok, show_live, _html} = live(conn, Routes.phx_admin_fantasy_team_show_path(conn, :show, fantasy_team))

      assert show_live |> element("a", "Edit") |> render_click() =~
        "Edit Fantasy team"

      assert_patch(show_live, Routes.phx_admin_fantasy_team_show_path(conn, :edit, fantasy_team))

      assert show_live
             |> form("#fantasy_team-form", fantasy_team: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#fantasy_team-form", fantasy_team: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.phx_admin_fantasy_team_show_path(conn, :show, fantasy_team))

      assert html =~ "Fantasy team updated successfully"
      assert html =~ "some updated autodraft_setting"
    end
  end
end
