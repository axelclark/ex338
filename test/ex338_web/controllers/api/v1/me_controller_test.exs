defmodule Ex338Web.Api.V1.MeControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts

  describe "GET /api/v1/me" do
    test "returns the authenticated user for a valid token", %{conn: conn} do
      user = insert(:user, admin: false)
      token = Accounts.create_user_api_token(user, "test")

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/v1/me")

      assert %{"user" => data} = json_response(conn, 200)
      assert data["id"] == user.id
      assert data["email"] == user.email
      assert data["admin"] == false
    end

    test "reports admin scope for admins", %{conn: conn} do
      user = insert(:user, admin: true)
      token = Accounts.create_user_api_token(user, "test")

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/v1/me")

      assert json_response(conn, 200)["user"]["admin"] == true
    end

    test "returns 401 when the token is missing", %{conn: conn} do
      conn = get(conn, ~p"/api/v1/me")

      assert json_response(conn, 401)["error"]
    end

    test "returns 401 for an invalid token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer not-a-real-token")
        |> get(~p"/api/v1/me")

      assert json_response(conn, 401)["error"]
    end
  end
end
