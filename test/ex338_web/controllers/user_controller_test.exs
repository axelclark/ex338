defmodule Ex338Web.UserControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts.User
  alias Ex338.Repo

  setup %{conn: conn} do
    user = insert(:user, name: "Brown", email: "test@example.com")
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "edit/2" do
    test "renders a form to update a user", %{conn: conn, user: user} do
      conn = get(conn, user_path(conn, :edit, user.id))

      assert html_response(conn, 200) =~ ~r/Update User Info/
      assert String.contains?(conn.resp_body, user.name)
      assert String.contains?(conn.resp_body, user.email)
    end

    test "redirects to root if user is not current user", %{conn: conn} do
      other_user = insert(:user)

      conn = get(conn, user_path(conn, :edit, other_user.id))

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end

  describe "show/2" do
    test "shows user info", %{conn: conn, user: user} do
      conn = get(conn, user_path(conn, :show, user.id))

      assert html_response(conn, 200) =~ ~r/Brown/
      assert String.contains?(conn.resp_body, user.name)
      assert String.contains?(conn.resp_body, user.email)
    end
  end

  describe "update/2" do
    test "updates user info and redirects", %{conn: conn, user: user} do
      new_name = "Nickname"
      new_email = "j@me.com"
      attrs = %{"name" => new_name, "email" => new_email}

      conn = patch(conn, user_path(conn, :update, user, user: attrs))

      [result] = Repo.all(User)

      assert redirected_to(conn) == user_path(conn, :show, user.id)
      assert result.email == new_email
      assert result.name == new_name
    end

    test "does not update and renders errors when invalid", %{conn: conn, user: user} do
      new_name = "Nickname"
      wrong_email = "j.com"
      attrs = %{"name" => new_name, "email" => wrong_email}

      conn = patch(conn, user_path(conn, :update, user, user: attrs))

      assert html_response(conn, 200) =~ "Please check the errors below."
    end

    test "redirects to root if user is not authorized", %{conn: conn} do
      other_user = insert(:user)
      new_name = "Nickname"
      new_email = "j@me.com"
      attrs = %{"name" => new_name, "email" => new_email}

      conn = patch(conn, user_path(conn, :update, other_user, user: attrs))

      assert html_response(conn, 302) =~ ~r/redirected/
    end
  end
end
