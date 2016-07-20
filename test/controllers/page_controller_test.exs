defmodule Ex338.PageControllerTest do
  use Ex338.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Welcome to the 338 Challenge!"
  end
end
