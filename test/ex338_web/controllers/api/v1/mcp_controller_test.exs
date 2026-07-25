defmodule Ex338Web.Api.V1.McpControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts
  alias Ex338.CalendarAssistant
  alias Ex338.Waivers.Waiver

  defp rpc(conn, user, payload) do
    token = Accounts.create_user_api_token(user, "test")

    conn
    |> put_req_header("authorization", "Bearer " <> token)
    |> put_req_header("content-type", "application/json")
    |> post(~p"/api/v1/mcp", Jason.encode!(payload))
  end

  defp call_tool(conn, user, name, arguments, id \\ 1) do
    rpc(conn, user, %{
      jsonrpc: "2.0",
      id: id,
      method: "tools/call",
      params: %{name: name, arguments: arguments}
    })
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

  describe "initialize / ping / method routing" do
    test "initialize returns protocol version and server info", %{conn: conn} do
      user = insert(:user)

      conn = rpc(conn, user, %{jsonrpc: "2.0", id: 1, method: "initialize", params: %{}})

      assert %{"id" => 1, "result" => result} = json_response(conn, 200)
      assert result["protocolVersion"]
      assert result["serverInfo"]["name"] == "ex338"
      assert result["capabilities"]["tools"]
    end

    test "unknown method returns JSON-RPC method-not-found", %{conn: conn} do
      user = insert(:user)

      conn = rpc(conn, user, %{jsonrpc: "2.0", id: 2, method: "does/not/exist", params: %{}})

      assert %{"error" => %{"code" => -32_601}} = json_response(conn, 200)
    end

    test "a notification (no id) gets 202 with no body", %{conn: conn} do
      user = insert(:user)

      conn = rpc(conn, user, %{jsonrpc: "2.0", method: "notifications/initialized"})

      assert response(conn, 202) == ""
    end

    test "returns 401 without a token", %{conn: conn} do
      conn =
        conn
        |> put_req_header("content-type", "application/json")
        |> post(~p"/api/v1/mcp", Jason.encode!(%{jsonrpc: "2.0", id: 1, method: "initialize"}))

      assert json_response(conn, 401)["error"]
    end
  end

  describe "tools/list" do
    test "advertises the available tools", %{conn: conn} do
      user = insert(:user)

      conn = rpc(conn, user, %{jsonrpc: "2.0", id: 1, method: "tools/list", params: %{}})

      assert %{"result" => %{"tools" => tools}} = json_response(conn, 200)
      names = Enum.map(tools, & &1["name"])
      assert "whoami" in names
      assert "list_league_waivers" in names
      assert "create_waiver" in names
      assert Enum.all?(tools, &is_map(&1["inputSchema"]))
    end
  end

  describe "tools/call whoami" do
    test "returns identity and admin scope", %{conn: conn} do
      user = insert(:user, admin: true)

      conn = call_tool(conn, user, "whoami", %{})

      assert %{"result" => %{"isError" => false, "content" => [content]}} =
               json_response(conn, 200)

      assert content["type"] == "text"
      assert Jason.decode!(content["text"])["admin"] == true
    end
  end

  describe "tools/call create_waiver" do
    test "an owner can create a waiver", %{conn: conn} do
      %{team: team, add: add, drop: drop} = setup_waiver_data()
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        call_tool(conn, user, "create_waiver", %{
          fantasy_team_id: team.id,
          add_fantasy_player_id: add.id,
          drop_fantasy_player_id: drop.id
        })

      assert %{"result" => %{"isError" => false, "content" => [content]}} =
               json_response(conn, 200)

      assert Jason.decode!(content["text"])["fantasy_team_id"] == team.id
      assert Repo.get_by(Waiver, fantasy_team_id: team.id)
    end

    test "a non-owner gets an isError tool result, not a crash", %{conn: conn} do
      %{team: team, add: add, drop: drop} = setup_waiver_data()
      stranger = insert(:user)

      conn =
        call_tool(conn, stranger, "create_waiver", %{
          fantasy_team_id: team.id,
          add_fantasy_player_id: add.id,
          drop_fantasy_player_id: drop.id
        })

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "not authorized"
      refute Repo.get_by(Waiver, fantasy_team_id: team.id)
    end

    test "invalid params surface a validation tool result", %{conn: conn} do
      %{team: team} = setup_waiver_data()
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn = call_tool(conn, user, "create_waiver", %{fantasy_team_id: team.id})

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "Validation failed"
    end

    test "an unknown tool returns a JSON-RPC invalid-params error", %{conn: conn} do
      user = insert(:user)

      conn = call_tool(conn, user, "no_such_tool", %{})

      assert %{"error" => %{"code" => -32_602}} = json_response(conn, 200)
    end
  end
end
