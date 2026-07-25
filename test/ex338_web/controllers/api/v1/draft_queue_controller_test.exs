defmodule Ex338Web.Api.V1.DraftQueueControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts
  alias Ex338.Audit
  alias Ex338.DraftQueues.DraftQueue

  defp auth(conn, user) do
    token = Accounts.create_user_api_token(user, "test")
    put_req_header(conn, "authorization", "Bearer " <> token)
  end

  describe "POST /api/v1/fantasy_teams/:fantasy_team_id/draft_queues" do
    setup do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)
      %{team: team, player: player}
    end

    test "an owner can queue a player", %{conn: conn} = ctx do
      %{team: team, player: player} = ctx
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        conn
        |> auth(user)
        |> post(~p"/api/v1/fantasy_teams/#{team.id}/draft_queues",
          draft_queue: %{fantasy_player_id: player.id}
        )

      assert %{"draft_queue" => data} = json_response(conn, 201)
      assert data["fantasy_player"]["id"] == player.id
      assert data["fantasy_team"]["id"] == team.id
      assert Repo.get_by(DraftQueue, fantasy_player_id: player.id, fantasy_team_id: team.id)

      assert [entry] = Audit.list_for_user(user.id)
      assert entry.action == "draft_queue.create"
      assert entry.source == "api"
      assert entry.outcome == "success"
    end

    test "a non-owner is forbidden and the denial is logged", %{conn: conn} = ctx do
      %{team: team, player: player} = ctx
      stranger = insert(:user)

      conn =
        conn
        |> auth(stranger)
        |> post(~p"/api/v1/fantasy_teams/#{team.id}/draft_queues",
          draft_queue: %{fantasy_player_id: player.id}
        )

      assert json_response(conn, 403)["error"]
      refute Repo.get_by(DraftQueue, fantasy_player_id: player.id)

      assert [entry] = Audit.list_for_user(stranger.id)
      assert entry.outcome == "denied"
    end

    test "returns 401 without a token", %{conn: conn} do
      conn = post(conn, ~p"/api/v1/fantasy_teams/1/draft_queues", draft_queue: %{})

      assert json_response(conn, 401)["error"]
    end
  end
end
