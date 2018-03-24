defmodule Ex338Web.PageControllerTest do
  use Ex338Web.ConnCase

  setup %{conn: conn} do
    user = %Ex338.User{name: "test", email: "test@example.com", id: 1}
    {:ok, conn: assign(conn, :current_user, user), user: user}
  end

  describe "GET /" do
    test "login is required" do
      conn = %Plug.Conn{}
      league = insert(:fantasy_league)

      conn = get(conn, fantasy_league_path(conn, :show, league.id))

      assert html_response(conn, 302) =~ "/sessions/new"
    end
  end

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to the 338 Challenge!"
  end

  test "GET /2017_rules", %{conn: conn} do
    conn = get(conn, "/2017_rules")
    assert html_response(conn, 200) =~ "338 Rules"
  end

  test "GET /2018_rules", %{conn: conn} do
    conn = get(conn, "/2018_rules")
    assert html_response(conn, 200) =~ "338 Rules"
  end

  test "Loads leagues into assigns", %{conn: conn} do
    league = insert(:fantasy_league)
    conn = get(conn, "/")
    assert conn.assigns.leagues == [league]
  end
end
