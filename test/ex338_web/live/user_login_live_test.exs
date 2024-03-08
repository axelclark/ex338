defmodule Ex338Web.UserLoginLiveTest do
  use Ex338Web.ConnCase, async: true

  import Ex338.AccountsFixtures
  import Phoenix.LiveViewTest

  describe "Log in page" do
    test "renders log in page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/users/log_in")

      assert html =~ "Sign in"
      assert html =~ "Forgot your password?"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/log_in")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end
  end

  describe "user login" do
    test "redirects if user login with valid credentials", %{conn: conn} do
      password = "123456789abcd"
      user = user_fixture(%{password: password})

      {:ok, view, _html} = live(conn, ~p"/users/log_in")

      form =
        form(view, "#login_form",
          user: %{email: user.email, password: password, remember_me: true}
        )

      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/"
    end

    test "redirects to login page with a flash error if there are no valid credentials", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/users/log_in")

      form =
        form(view, "#login_form",
          user: %{email: "test@email.com", password: "123456", remember_me: true}
        )

      conn = submit_form(form, conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"

      assert redirected_to(conn) == "/users/log_in"
    end
  end

  describe "login navigation" do
    test "redirects to forgot password page when the Forgot Password button is clicked", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/users/log_in")

      {:ok, conn} =
        view
        |> element(~s|main a:fl-contains("Forgot your password?")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/reset_password")

      assert conn.resp_body =~ "Forgot your password?"
    end
  end
end
