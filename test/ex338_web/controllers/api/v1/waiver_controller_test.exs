defmodule Ex338Web.Api.V1.WaiverControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts
  alias Ex338.CalendarAssistant
  alias Ex338.Waivers.Waiver

  defp auth(conn, user) do
    token = Accounts.create_user_api_token(user, "test")
    put_req_header(conn, "authorization", "Bearer " <> token)
  end

  defp setup_waiver_data do
    league = insert(:fantasy_league)
    team = insert(:fantasy_team, fantasy_league: league)
    sports_league = insert(:sports_league)
    insert(:league_sport, fantasy_league: league, sports_league: sports_league)

    insert(:championship,
      sports_league: sports_league,
      waiver_deadline_at: CalendarAssistant.days_from_now(1),
      championship_at: CalendarAssistant.days_from_now(9)
    )

    add = insert(:fantasy_player, sports_league: sports_league)
    drop = insert(:fantasy_player, sports_league: sports_league)
    insert(:roster_position, fantasy_player: drop, fantasy_team: team)

    %{team: team, add: add, drop: drop}
  end

  describe "POST /api/v1/fantasy_teams/:fantasy_team_id/waivers" do
    test "an owner can create a waiver for their team", %{conn: conn} do
      %{team: team, add: add, drop: drop} = setup_waiver_data()
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)
      attrs = %{add_fantasy_player_id: add.id, drop_fantasy_player_id: drop.id}

      conn =
        conn
        |> auth(user)
        |> post(~p"/api/v1/fantasy_teams/#{team.id}/waivers", waiver: attrs)

      assert %{"waiver" => data} = json_response(conn, 201)
      assert data["fantasy_team"]["id"] == team.id
      assert Repo.get_by!(Waiver, attrs).fantasy_team_id == team.id
    end

    test "an admin can create a waiver for any team", %{conn: conn} do
      %{team: team, add: add, drop: drop} = setup_waiver_data()
      admin = insert(:user, admin: true)
      attrs = %{add_fantasy_player_id: add.id, drop_fantasy_player_id: drop.id}

      conn =
        conn
        |> auth(admin)
        |> post(~p"/api/v1/fantasy_teams/#{team.id}/waivers", waiver: attrs)

      assert json_response(conn, 201)
    end

    test "a non-owner is forbidden", %{conn: conn} do
      %{team: team, add: add, drop: drop} = setup_waiver_data()
      stranger = insert(:user)
      attrs = %{add_fantasy_player_id: add.id, drop_fantasy_player_id: drop.id}

      conn =
        conn
        |> auth(stranger)
        |> post(~p"/api/v1/fantasy_teams/#{team.id}/waivers", waiver: attrs)

      assert json_response(conn, 403)["error"]
      refute Repo.get_by(Waiver, attrs)
    end

    test "returns 422 with errors for invalid params", %{conn: conn} do
      %{team: team} = setup_waiver_data()
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        conn
        |> auth(user)
        |> post(~p"/api/v1/fantasy_teams/#{team.id}/waivers", waiver: %{})

      assert %{"error" => _, "errors" => errors} = json_response(conn, 422)
      assert is_map(errors)
    end

    test "returns 404 for a non-existent team", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> auth(user)
        |> post(~p"/api/v1/fantasy_teams/0/waivers", waiver: %{})

      assert json_response(conn, 404)["error"]
    end

    test "returns 401 without a token", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/fantasy_teams/1/waivers", waiver: %{})

      assert json_response(conn, 401)["error"]
    end
  end

  describe "GET /api/v1/fantasy_leagues/:fantasy_league_id/waivers" do
    test "returns waivers for a league", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, waiver_position: 1)
      add_player = insert(:fantasy_player)
      drop_player = insert(:fantasy_player)

      insert(:waiver,
        fantasy_team: team,
        add_fantasy_player: add_player,
        drop_fantasy_player: drop_player,
        status: "successful"
      )

      conn = get(conn, ~p"/api/v1/fantasy_leagues/#{league.id}/waivers")

      assert %{"waivers" => waivers} = json_response(conn, 200)
      assert length(waivers) == 1
      [waiver] = waivers
      assert waiver["status"] == "successful"
      assert waiver["fantasy_team"]["team_name"]
      assert waiver["add_fantasy_player"]["player_name"]
      assert waiver["drop_fantasy_player"]["player_name"]
    end
  end
end
