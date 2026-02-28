defmodule Ex338Web.HealthControllerTest do
  use Ex338Web.ConnCase

  test "GET /health returns 200", %{conn: conn} do
    conn = get(conn, "/health")

    assert response(conn, 200) == "ok"
  end
end
