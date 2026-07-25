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

    test "returns each team the owner has with the league it plays in", %{conn: conn} do
      user = insert(:user)
      league_b = insert(:fantasy_league, division: "B")
      league_c = insert(:fantasy_league, division: "C")
      team_b = insert(:fantasy_team, team_name: "B Squad", fantasy_league: league_b)
      team_c = insert(:fantasy_team, team_name: "C Squad", fantasy_league: league_c)
      insert(:owner, fantasy_team: team_b, user: user)
      insert(:owner, fantasy_team: team_c, user: user)
      token = Accounts.create_user_api_token(user, "test")

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/v1/me")

      assert %{"user" => %{"fantasy_teams" => teams}} = json_response(conn, 200)
      assert length(teams) == 2

      by_name = Map.new(teams, &{&1["team_name"], &1})
      assert by_name["B Squad"]["id"] == team_b.id
      assert by_name["B Squad"]["fantasy_league"]["id"] == league_b.id
      assert by_name["B Squad"]["fantasy_league"]["division"] == "B"
      assert by_name["C Squad"]["fantasy_league"]["id"] == league_c.id
    end

    test "returns an empty team list for a user who owns none", %{conn: conn} do
      user = insert(:user)
      token = Accounts.create_user_api_token(user, "test")

      conn =
        conn
        |> put_req_header("authorization", "Bearer " <> token)
        |> get(~p"/api/v1/me")

      assert json_response(conn, 200)["user"]["fantasy_teams"] == []
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
