defmodule Ex338.CoherenceRegisterControllerTest do
  use Ex338.ConnCase
  import Ex338.Router.Helpers

  @base_attrs %{email: "some@content", name: "some content"}
  @valid_attrs Enum.into [password: "secret", password_confirmation: "secret"], @base_attrs
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: conn}
  end

  test "renders form for new registration", %{conn: conn} do
    conn = get conn, registration_path(conn, :new)
    assert html_response(conn, 200) =~ "Register Account"
  end

  test "creates account", %{conn: conn} do
    conn = post conn, registration_path(conn, :create), registration: @valid_attrs
    assert redirected_to(conn) == "/"
    assert html_response(conn, 302) =~ "redirected"
  end

  test "redirects to registration new with invalid info", %{conn: conn} do
    conn = post conn, registration_path(conn, :create), registration: @invalid_attrs
    assert html_response(conn, 200) =~ "Oops, something went wrong!"
  end
end
