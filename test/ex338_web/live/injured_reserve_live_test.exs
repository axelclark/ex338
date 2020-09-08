defmodule Ex338Web.InjuredReserveLiveTest do
  use Ex338Web.ConnCase

  import Phoenix.LiveViewTest

  alias Ex338.InjuredReserves

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp fixture(:injured_reserve) do
    {:ok, injured_reserve} = InjuredReserves.create_injured_reserve(@create_attrs)
    injured_reserve
  end

  defp create_injured_reserve(_) do
    injured_reserve = fixture(:injured_reserve)
    %{injured_reserve: injured_reserve}
  end

  describe "Index" do
    setup [:create_injured_reserve]

    test "lists all injured_reserves", %{conn: conn, injured_reserve: injured_reserve} do
      {:ok, _index_live, html} = live(conn, Routes.injured_reserve_index_path(conn, :index))

      assert html =~ "Listing Injured reserves"
    end

    test "saves new injured_reserve", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.injured_reserve_index_path(conn, :index))

      assert index_live |> element("a", "New Injured reserve") |> render_click() =~
               "New Injured reserve"

      assert_patch(index_live, Routes.injured_reserve_index_path(conn, :new))

      assert index_live
             |> form("#injured_reserve-form", injured_reserve: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#injured_reserve-form", injured_reserve: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.injured_reserve_index_path(conn, :index))

      assert html =~ "Injured reserve created successfully"
    end

    test "updates injured_reserve in listing", %{conn: conn, injured_reserve: injured_reserve} do
      {:ok, index_live, _html} = live(conn, Routes.injured_reserve_index_path(conn, :index))

      assert index_live |> element("#injured_reserve-#{injured_reserve.id} a", "Edit") |> render_click() =~
               "Edit Injured reserve"

      assert_patch(index_live, Routes.injured_reserve_index_path(conn, :edit, injured_reserve))

      assert index_live
             |> form("#injured_reserve-form", injured_reserve: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#injured_reserve-form", injured_reserve: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.injured_reserve_index_path(conn, :index))

      assert html =~ "Injured reserve updated successfully"
    end

    test "deletes injured_reserve in listing", %{conn: conn, injured_reserve: injured_reserve} do
      {:ok, index_live, _html} = live(conn, Routes.injured_reserve_index_path(conn, :index))

      assert index_live |> element("#injured_reserve-#{injured_reserve.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#injured_reserve-#{injured_reserve.id}")
    end
  end

  describe "Show" do
    setup [:create_injured_reserve]

    test "displays injured_reserve", %{conn: conn, injured_reserve: injured_reserve} do
      {:ok, _show_live, html} = live(conn, Routes.injured_reserve_show_path(conn, :show, injured_reserve))

      assert html =~ "Show Injured reserve"
    end

    test "updates injured_reserve within modal", %{conn: conn, injured_reserve: injured_reserve} do
      {:ok, show_live, _html} = live(conn, Routes.injured_reserve_show_path(conn, :show, injured_reserve))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Injured reserve"

      assert_patch(show_live, Routes.injured_reserve_show_path(conn, :edit, injured_reserve))

      assert show_live
             |> form("#injured_reserve-form", injured_reserve: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#injured_reserve-form", injured_reserve: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.injured_reserve_show_path(conn, :show, injured_reserve))

      assert html =~ "Injured reserve updated successfully"
    end
  end
end
