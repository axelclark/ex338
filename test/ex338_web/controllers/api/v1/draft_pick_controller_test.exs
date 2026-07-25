defmodule Ex338Web.Api.V1.DraftPickControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts
  alias Ex338.Audit
  alias Ex338.DraftPicks.DraftPick
  alias Ex338.RosterPositions.RosterPosition

  defp auth(conn, user) do
    token = Accounts.create_user_api_token(user, "test")
    put_req_header(conn, "authorization", "Bearer " <> token)
  end

  defp setup_draft_data(league_attrs \\ []) do
    league = insert(:fantasy_league, league_attrs)
    team = insert(:fantasy_team, fantasy_league: league)
    player = insert(:fantasy_player)
    pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team, fantasy_league: league)

    %{league: league, team: team, player: player, pick: pick}
  end

  describe "GET /api/v1/fantasy_leagues/:fantasy_league_id/draft_picks" do
    test "returns draft picks for a league", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, waiver_position: 1)
      sport = insert(:sports_league)
      player = insert(:fantasy_player, sports_league: sport)

      insert(:draft_pick,
        fantasy_league: league,
        fantasy_team: team,
        fantasy_player: player,
        draft_position: 1.01
      )

      conn = get(conn, ~p"/api/v1/fantasy_leagues/#{league.id}/draft_picks")

      assert %{"draft_picks" => picks} = json_response(conn, 200)
      assert length(picks) == 1
      [pick] = picks
      assert pick["draft_position"]
      assert pick["fantasy_team"]["team_name"]
      assert pick["fantasy_player"]["player_name"]
    end
  end

  describe "POST /api/v1/draft_picks/:id/draft_player" do
    test "an owner can draft a player with their pick", %{conn: conn} do
      %{team: team, player: player, pick: pick} = setup_draft_data()
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        conn
        |> auth(user)
        |> post(~p"/api/v1/draft_picks/#{pick.id}/draft_player",
          draft_pick: %{fantasy_player_id: player.id}
        )

      assert %{"draft_pick" => data} = json_response(conn, 200)
      assert data["fantasy_player"]["id"] == player.id
      assert data["drafted_at"]
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == player.id
      assert Repo.get_by(RosterPosition, fantasy_team_id: team.id, fantasy_player_id: player.id)

      assert [entry] = Audit.list_for_user(user.id)
      assert entry.action == "draft_pick.draft_player"
      assert entry.source == "api"
      assert entry.outcome == "success"
    end

    test "an admin can draft with another team's pick", %{conn: conn} do
      %{player: player, pick: pick} = setup_draft_data()
      admin = insert(:user, admin: true)

      conn =
        conn
        |> auth(admin)
        |> post(~p"/api/v1/draft_picks/#{pick.id}/draft_player",
          draft_pick: %{fantasy_player_id: player.id}
        )

      assert json_response(conn, 200)["draft_pick"]
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == player.id
    end

    test "a non-owner is forbidden and the denial is logged", %{conn: conn} do
      %{player: player, pick: pick} = setup_draft_data()
      stranger = insert(:user)

      conn =
        conn
        |> auth(stranger)
        |> post(~p"/api/v1/draft_picks/#{pick.id}/draft_player",
          draft_pick: %{fantasy_player_id: player.id}
        )

      assert json_response(conn, 403)["error"]
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == nil

      assert [entry] = Audit.list_for_user(stranger.id)
      assert entry.outcome == "denied"
    end

    test "returns 422 when the league's draft picks are locked", %{conn: conn} do
      %{team: team, player: player, pick: pick} = setup_draft_data(draft_picks_locked?: true)
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        conn
        |> auth(user)
        |> post(~p"/api/v1/draft_picks/#{pick.id}/draft_player",
          draft_pick: %{fantasy_player_id: player.id}
        )

      assert json_response(conn, 422)["error"] =~ "locked"
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == nil
    end

    test "returns 422 without a player", %{conn: conn} do
      %{team: team, pick: pick} = setup_draft_data()
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        conn
        |> auth(user)
        |> post(~p"/api/v1/draft_picks/#{pick.id}/draft_player", draft_pick: %{})

      assert json_response(conn, 422)["errors"]
    end

    test "returns 422 for a player that doesn't exist", %{conn: conn} do
      %{team: team, pick: pick} = setup_draft_data()
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        conn
        |> auth(user)
        |> post(~p"/api/v1/draft_picks/#{pick.id}/draft_player",
          draft_pick: %{fantasy_player_id: 999_999}
        )

      assert %{"errors" => %{"fantasy_player_id" => ["is invalid"]}} = json_response(conn, 422)
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == nil
    end

    test "returns 422 for a pick with no team assigned", %{conn: conn} do
      league = insert(:fantasy_league)
      player = insert(:fantasy_player)

      pick =
        insert(:draft_pick, draft_position: 1.01, fantasy_league: league, fantasy_team: nil)

      admin = insert(:user, admin: true)

      conn =
        conn
        |> auth(admin)
        |> post(~p"/api/v1/draft_picks/#{pick.id}/draft_player",
          draft_pick: %{fantasy_player_id: player.id}
        )

      assert %{"errors" => %{"fantasy_team_id" => _}} = json_response(conn, 422)
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == nil
    end

    test "returns 404 for a missing pick", %{conn: conn} do
      user = insert(:user)

      conn =
        conn
        |> auth(user)
        |> post(~p"/api/v1/draft_picks/0/draft_player", draft_pick: %{fantasy_player_id: 1})

      assert json_response(conn, 404)["error"]
    end

    test "returns 401 without a token", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/draft_picks/1/draft_player", draft_pick: %{})

      assert json_response(conn, 401)["error"]
    end
  end

  describe "PATCH /api/v1/draft_picks/:id" do
    test "an admin can correct a pick's fields", %{conn: conn} do
      %{league: league, pick: pick} = setup_draft_data()
      other_team = insert(:fantasy_team, fantasy_league: league)
      admin = insert(:user, admin: true)

      conn =
        conn
        |> auth(admin)
        |> patch(~p"/api/v1/draft_picks/#{pick.id}",
          draft_pick: %{fantasy_team_id: other_team.id, is_keeper: true}
        )

      assert %{"draft_pick" => data} = json_response(conn, 200)
      assert data["is_keeper"] == true
      assert data["fantasy_team"]["id"] == other_team.id

      updated_pick = Repo.get!(DraftPick, pick.id)
      assert updated_pick.fantasy_team_id == other_team.id
      assert updated_pick.is_keeper == true

      assert [entry] = Audit.list_for_user(admin.id)
      assert entry.action == "draft_pick.update"
      assert entry.source == "api"
    end

    test "an owner cannot update their own pick's fields", %{conn: conn} do
      %{team: team, pick: pick} = setup_draft_data()
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        conn
        |> auth(user)
        |> patch(~p"/api/v1/draft_picks/#{pick.id}", draft_pick: %{is_keeper: true})

      assert json_response(conn, 403)["error"]
      assert Repo.get!(DraftPick, pick.id).is_keeper == false

      assert [entry] = Audit.list_for_user(user.id)
      assert entry.outcome == "denied"
    end

    test "omits pick_number rather than reporting it as null", %{conn: conn} do
      %{pick: pick} = setup_draft_data()
      admin = insert(:user, admin: true)

      conn =
        conn
        |> auth(admin)
        |> patch(~p"/api/v1/draft_picks/#{pick.id}", draft_pick: %{is_keeper: true})

      assert %{"draft_pick" => data} = json_response(conn, 200)
      refute Map.has_key?(data, "pick_number")
    end

    test "the league cannot be reassigned", %{conn: conn} do
      %{league: league, pick: pick} = setup_draft_data()
      other_league = insert(:fantasy_league)
      admin = insert(:user, admin: true)

      conn =
        conn
        |> auth(admin)
        |> patch(~p"/api/v1/draft_picks/#{pick.id}",
          draft_pick: %{fantasy_league_id: other_league.id}
        )

      assert json_response(conn, 200)["draft_pick"]
      assert Repo.get!(DraftPick, pick.id).fantasy_league_id == league.id
    end

    test "the drafted player cannot be changed or cleared", %{conn: conn} do
      %{league: league, team: team, player: player} = setup_draft_data()

      pick =
        insert(:draft_pick,
          draft_position: 1.01,
          fantasy_league: league,
          fantasy_team: team,
          fantasy_player: player
        )

      admin = insert(:user, admin: true)

      conn =
        conn
        |> auth(admin)
        |> patch(~p"/api/v1/draft_picks/#{pick.id}", draft_pick: %{fantasy_player_id: nil})

      assert json_response(conn, 200)["draft_pick"]
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == player.id
    end

    test "returns 422 when the team is cleared", %{conn: conn} do
      %{pick: pick} = setup_draft_data()
      admin = insert(:user, admin: true)

      conn =
        conn
        |> auth(admin)
        |> patch(~p"/api/v1/draft_picks/#{pick.id}", draft_pick: %{fantasy_team_id: nil})

      assert %{"errors" => %{"fantasy_team_id" => ["can't be blank"]}} = json_response(conn, 422)
      refute is_nil(Repo.get!(DraftPick, pick.id).fantasy_team_id)
    end

    test "returns 422 for a team in another league", %{conn: conn} do
      %{team: team, pick: pick} = setup_draft_data()
      other_league_team = insert(:fantasy_team, fantasy_league: insert(:fantasy_league))
      admin = insert(:user, admin: true)

      conn =
        conn
        |> auth(admin)
        |> patch(~p"/api/v1/draft_picks/#{pick.id}",
          draft_pick: %{fantasy_team_id: other_league_team.id}
        )

      assert %{"errors" => %{"fantasy_team_id" => ["must belong to the pick's league"]}} =
               json_response(conn, 422)

      assert Repo.get!(DraftPick, pick.id).fantasy_team_id == team.id
    end

    test "returns 422 for a team that doesn't exist", %{conn: conn} do
      %{team: team, pick: pick} = setup_draft_data()
      admin = insert(:user, admin: true)

      conn =
        conn
        |> auth(admin)
        |> patch(~p"/api/v1/draft_picks/#{pick.id}", draft_pick: %{fantasy_team_id: 999_999})

      assert %{"errors" => %{"fantasy_team_id" => ["does not exist"]}} = json_response(conn, 422)
      assert Repo.get!(DraftPick, pick.id).fantasy_team_id == team.id
    end

    test "returns 422 when moving a pick that has already been used", %{conn: conn} do
      %{league: league, team: team, player: player} = setup_draft_data()
      other_team = insert(:fantasy_team, fantasy_league: league)

      pick =
        insert(:draft_pick,
          draft_position: 1.01,
          fantasy_league: league,
          fantasy_team: team,
          fantasy_player: player
        )

      admin = insert(:user, admin: true)

      conn =
        conn
        |> auth(admin)
        |> patch(~p"/api/v1/draft_picks/#{pick.id}",
          draft_pick: %{fantasy_team_id: other_team.id}
        )

      assert %{"errors" => %{"fantasy_team_id" => [message]}} = json_response(conn, 422)
      assert message =~ "once the pick has been used"
      assert Repo.get!(DraftPick, pick.id).fantasy_team_id == team.id
    end

    test "returns 401 without a token", %{conn: conn} do
      conn = patch(conn, ~p"/api/v1/draft_picks/1", draft_pick: %{})

      assert json_response(conn, 401)["error"]
    end
  end
end
