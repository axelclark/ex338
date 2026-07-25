defmodule Ex338Web.Api.V1.InjuredReserveControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts
  alias Ex338.Audit
  alias Ex338.InjuredReserves.InjuredReserve

  defp auth(conn, user) do
    token = Accounts.create_user_api_token(user, "test")
    put_req_header(conn, "authorization", "Bearer " <> token)
  end

  describe "POST /api/v1/fantasy_teams/:fantasy_team_id/injured_reserves" do
    setup do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      injured = insert(:fantasy_player)
      replacement = insert(:fantasy_player)
      %{team: team, injured: injured, replacement: replacement}
    end

    test "an owner can create an IR request", %{conn: conn} = ctx do
      %{team: team, injured: injured, replacement: replacement} = ctx
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)
      attrs = %{injured_player_id: injured.id, replacement_player_id: replacement.id}

      conn =
        conn
        |> auth(user)
        |> post(~p"/api/v1/fantasy_teams/#{team.id}/injured_reserves", injured_reserve: attrs)

      assert %{"injured_reserve" => data} = json_response(conn, 201)
      assert data["fantasy_team"]["id"] == team.id
      assert Repo.get_by(InjuredReserve, injured_player_id: injured.id)

      assert [entry] = Audit.list_for_user(user.id)
      assert entry.action == "injured_reserve.create"
      assert entry.source == "api"
      assert entry.outcome == "success"
    end

    test "ignores a client-supplied status so IRs start as submitted", %{conn: conn} = ctx do
      %{team: team, injured: injured, replacement: replacement} = ctx
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      attrs = %{
        injured_player_id: injured.id,
        replacement_player_id: replacement.id,
        status: "approved"
      }

      conn =
        conn
        |> auth(user)
        |> post(~p"/api/v1/fantasy_teams/#{team.id}/injured_reserves", injured_reserve: attrs)

      assert %{"injured_reserve" => data} = json_response(conn, 201)
      assert data["status"] == "submitted"
      assert Repo.get_by(InjuredReserve, injured_player_id: injured.id).status == :submitted
    end

    test "ignores a body fantasy_team_id and writes to the authorized team",
         %{conn: conn} = ctx do
      %{team: team, injured: injured, replacement: replacement} = ctx
      other_team = insert(:fantasy_team)
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      attrs = %{
        fantasy_team_id: other_team.id,
        injured_player_id: injured.id,
        replacement_player_id: replacement.id
      }

      conn =
        conn
        |> auth(user)
        |> post(~p"/api/v1/fantasy_teams/#{team.id}/injured_reserves", injured_reserve: attrs)

      assert %{"injured_reserve" => data} = json_response(conn, 201)
      assert data["fantasy_team"]["id"] == team.id
      refute Repo.get_by(InjuredReserve, fantasy_team_id: other_team.id)
    end

    test "a non-owner is forbidden and the denial is logged", %{conn: conn} = ctx do
      %{team: team, injured: injured, replacement: replacement} = ctx
      stranger = insert(:user)
      attrs = %{injured_player_id: injured.id, replacement_player_id: replacement.id}

      conn =
        conn
        |> auth(stranger)
        |> post(~p"/api/v1/fantasy_teams/#{team.id}/injured_reserves", injured_reserve: attrs)

      assert json_response(conn, 403)["error"]
      refute Repo.get_by(InjuredReserve, injured_player_id: injured.id)

      assert [entry] = Audit.list_for_user(stranger.id)
      assert entry.outcome == "denied"
    end

    test "returns 401 without a token", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/fantasy_teams/1/injured_reserves", injured_reserve: %{})

      assert json_response(conn, 401)["error"]
    end
  end

  describe "GET /api/v1/fantasy_leagues/:fantasy_league_id/injured_reserves" do
    test "returns injured reserves for a league", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, waiver_position: 1)
      injured_player = insert(:fantasy_player)
      replacement_player = insert(:fantasy_player)

      insert(:injured_reserve,
        fantasy_team: team,
        injured_player: injured_player,
        replacement_player: replacement_player,
        status: "approved"
      )

      conn = get(conn, ~p"/api/v1/fantasy_leagues/#{league.id}/injured_reserves")

      assert %{"injured_reserves" => irs} = json_response(conn, 200)
      assert length(irs) == 1
      [ir] = irs
      assert ir["status"] == "approved"
      assert ir["fantasy_team"]["team_name"]
      assert ir["injured_player"]["player_name"]
      assert ir["replacement_player"]["player_name"]
    end
  end
end
