defmodule Ex338.PageControllerTest do
  use Ex338.ConnCase

  setup %{conn: conn} do
    user = %Ex338.User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "GET /" do
    test "login is required" do
      conn = %Plug.Conn{}
      league = insert(:fantasy_league)

      conn = get conn, fantasy_league_path(conn, :show, league.id)

      assert html_response(conn, 200) =~ "action=\"/sessions\""
      assert conn.resp_body =~ "Email"
      assert conn.resp_body =~ "Password"
    end
  end

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to the 338 Challenge!"
  end

  test "GET /rules", %{conn: conn} do
    conn = get conn, "/rules"
    assert html_response(conn, 200) =~ "338 Rules"
  end
end
