defmodule Ex338Web.Api.V1.PrivateLeagueAccessTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts

  defp auth(conn, user) do
    token = Accounts.create_user_api_token(user, "test")
    put_req_header(conn, "authorization", "Bearer " <> token)
  end

  describe "league index visibility" do
    test "anonymous callers see public leagues but not private leagues", %{conn: conn} do
      public = insert(:fantasy_league, navbar_display: "primary", private?: false)
      private = insert(:fantasy_league, navbar_display: "primary", private?: true)

      conn = get(conn, ~p"/api/v1/fantasy_leagues")

      ids = conn |> json_response(200) |> get_in(["fantasy_leagues"]) |> Enum.map(& &1["id"])
      assert public.id in ids
      refute private.id in ids
    end

    test "members and admins see private leagues", %{conn: conn} do
      private = insert(:fantasy_league, navbar_display: "primary", private?: true)
      team = insert(:fantasy_team, fantasy_league: private)
      member = insert(:user)
      insert(:owner, fantasy_team: team, user: member)

      member_conn = conn |> auth(member) |> get(~p"/api/v1/fantasy_leagues")

      admin_conn =
        conn |> recycle() |> auth(insert(:user, admin: true)) |> get(~p"/api/v1/fantasy_leagues")

      assert private.id in league_ids(member_conn)
      assert private.id in league_ids(admin_conn)
    end

    test "authenticated non-members do not see private leagues", %{conn: conn} do
      private = insert(:fantasy_league, navbar_display: "primary", private?: true)

      conn = conn |> auth(insert(:user)) |> get(~p"/api/v1/fantasy_leagues")

      refute private.id in league_ids(conn)
    end

    test "an invalid supplied token returns 401", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer invalid")
        |> get(~p"/api/v1/fantasy_leagues")

      assert json_response(conn, 401)["error"]
    end
  end

  describe "private league reads" do
    setup do
      league = insert(:fantasy_league, private?: true)
      team = insert(:fantasy_team, fantasy_league: league)
      member = insert(:user)
      insert(:owner, fantasy_team: team, user: member)
      %{league: league, member: member, team: team}
    end

    test "every league-scoped read requires a token", %{conn: conn, league: league} do
      paths = [
        ~p"/api/v1/fantasy_leagues/#{league.id}",
        ~p"/api/v1/fantasy_leagues/#{league.id}/draft_picks",
        ~p"/api/v1/fantasy_leagues/#{league.id}/waivers",
        ~p"/api/v1/fantasy_leagues/#{league.id}/championships",
        ~p"/api/v1/fantasy_leagues/#{league.id}/championships/0",
        ~p"/api/v1/fantasy_leagues/#{league.id}/fantasy_players",
        ~p"/api/v1/fantasy_leagues/#{league.id}/trades",
        ~p"/api/v1/fantasy_leagues/#{league.id}/injured_reserves"
      ]

      for path <- paths do
        response = conn |> recycle() |> get(path)
        assert json_response(response, 401)["error"] =~ "API token"
      end
    end

    test "members and admins can view a private league", context do
      %{conn: conn, league: league, member: member} = context

      member_conn = conn |> auth(member) |> get(~p"/api/v1/fantasy_leagues/#{league.id}")

      admin_conn =
        conn
        |> recycle()
        |> auth(insert(:user, admin: true))
        |> get(~p"/api/v1/fantasy_leagues/#{league.id}")

      assert json_response(member_conn, 200)["fantasy_league"]["id"] == league.id
      assert json_response(admin_conn, 200)["fantasy_league"]["id"] == league.id
    end

    test "an authenticated non-member receives 403", %{conn: conn, league: league} do
      conn = conn |> auth(insert(:user)) |> get(~p"/api/v1/fantasy_leagues/#{league.id}")

      assert json_response(conn, 403)["error"] =~ "not authorized"
    end

    test "team reads use the team's private league access", context do
      %{conn: conn, member: member, team: team} = context
      path = ~p"/api/v1/fantasy_teams/#{team.id}"

      assert conn |> recycle() |> get(path) |> json_response(401)
      assert conn |> recycle() |> auth(insert(:user)) |> get(path) |> json_response(403)
      assert conn |> recycle() |> auth(member) |> get(path) |> json_response(200)
    end
  end

  test "public league and team reads remain anonymous", %{conn: conn} do
    league = insert(:fantasy_league, private?: false)
    team = insert(:fantasy_team, fantasy_league: league)

    assert conn |> get(~p"/api/v1/fantasy_leagues/#{league.id}") |> json_response(200)
    assert conn |> recycle() |> get(~p"/api/v1/fantasy_teams/#{team.id}") |> json_response(200)
  end

  defp league_ids(conn) do
    conn
    |> json_response(200)
    |> get_in(["fantasy_leagues"])
    |> Enum.map(& &1["id"])
  end
end
