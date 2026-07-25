defmodule Ex338Web.Api.V1.McpControllerTest do
  use Ex338Web.ConnCase

  alias Ex338.Accounts
  alias Ex338.Audit
  alias Ex338.CalendarAssistant
  alias Ex338.DraftPicks.DraftPick
  alias Ex338.DraftQueues.DraftQueue
  alias Ex338.RosterPositions.RosterPosition
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

  defp setup_draft_data(league_attrs \\ []) do
    league = insert(:fantasy_league, league_attrs)
    team = insert(:fantasy_team, fantasy_league: league)
    player = insert(:fantasy_player)
    pick = insert(:draft_pick, draft_position: 1.01, fantasy_team: team, fantasy_league: league)

    %{league: league, team: team, player: player, pick: pick}
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
      assert "list_league_draft_picks" in names
      assert "draft_player" in names
      assert "update_draft_pick" in names
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

      assert [entry] = Audit.list_for_user(user.id)
      assert entry.source == "mcp"
      assert entry.action == "waiver.create"
      assert entry.outcome == "success"
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

    test "a non-integer id returns a clean tool error, not a 500", %{conn: conn} do
      user = insert(:user)

      conn = call_tool(conn, user, "list_league_waivers", %{fantasy_league_id: "abc"})

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "Not found"
    end

    test "a non-integer team id on a write tool returns a clean tool error", %{conn: conn} do
      user = insert(:user)

      conn =
        call_tool(conn, user, "create_waiver", %{
          fantasy_team_id: "abc",
          add_fantasy_player_id: 1
        })

      assert %{"result" => %{"isError" => true}} = json_response(conn, 200)
    end
  end

  describe "tools/call create_injured_reserve" do
    test "an owner can create an IR request", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      injured = insert(:fantasy_player)
      replacement = insert(:fantasy_player)
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        call_tool(conn, user, "create_injured_reserve", %{
          fantasy_team_id: team.id,
          injured_player_id: injured.id,
          replacement_player_id: replacement.id
        })

      assert %{"result" => %{"isError" => false, "content" => [content]}} =
               json_response(conn, 200)

      assert Jason.decode!(content["text"])["fantasy_team_id"] == team.id

      assert [entry] = Audit.list_for_user(user.id)
      assert entry.action == "injured_reserve.create"
      assert entry.source == "mcp"
    end
  end

  describe "tools/call create_draft_queue" do
    test "an owner can queue a player", %{conn: conn} do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        call_tool(conn, user, "create_draft_queue", %{
          fantasy_team_id: team.id,
          fantasy_player_id: player.id
        })

      assert %{"result" => %{"isError" => false, "content" => [content]}} =
               json_response(conn, 200)

      assert Jason.decode!(content["text"])["fantasy_player_id"] == player.id

      assert [entry] = Audit.list_for_user(user.id)
      assert entry.action == "draft_queue.create"
      assert entry.source == "mcp"
    end
  end

  describe "tools/call list_team_draft_queues scoping" do
    test "an owner can read their team's queue", %{conn: conn} do
      team = insert(:fantasy_team)
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)
      insert(:draft_queue, fantasy_team: team, fantasy_player: insert(:fantasy_player))

      conn = call_tool(conn, user, "list_team_draft_queues", %{fantasy_team_id: team.id})

      assert %{"result" => %{"isError" => false, "content" => [content]}} =
               json_response(conn, 200)

      assert length(Jason.decode!(content["text"])["draft_queues"]) == 1
    end

    test "a non-owner cannot read another team's queue", %{conn: conn} do
      team = insert(:fantasy_team)
      outsider = insert(:user)

      conn = call_tool(conn, outsider, "list_team_draft_queues", %{fantasy_team_id: team.id})

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "not authorized"
    end
  end

  describe "tools/call list_league_draft_picks" do
    test "returns the draft board with which picks are available", %{conn: conn} do
      %{league: league, team: team, pick: pick} = setup_draft_data()
      user = insert(:user)

      conn = call_tool(conn, user, "list_league_draft_picks", %{fantasy_league_id: league.id})

      assert %{"result" => %{"isError" => false, "content" => [content]}} =
               json_response(conn, 200)

      assert %{"draft_picks" => [board_pick]} = Jason.decode!(content["text"])
      assert board_pick["id"] == pick.id
      assert board_pick["team_name"] == team.team_name
      assert board_pick["pick_number"] == 1
      assert board_pick["available_to_pick?"] == true
      assert board_pick["fantasy_player_id"] == nil
    end

    test "a non-member cannot read a private league's board", %{conn: conn} do
      %{league: league} = setup_draft_data(private?: true)
      outsider = insert(:user)

      conn = call_tool(conn, outsider, "list_league_draft_picks", %{fantasy_league_id: league.id})

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "not authorized"
    end
  end

  describe "tools/call draft_player" do
    test "an owner can draft a player with their pick", %{conn: conn} do
      %{team: team, player: player, pick: pick} = setup_draft_data()
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)
      queue = insert(:draft_queue, fantasy_team: team, fantasy_player: player)

      conn =
        call_tool(conn, user, "draft_player", %{
          draft_pick_id: pick.id,
          fantasy_player_id: player.id
        })

      assert %{"result" => %{"isError" => false, "content" => [content]}} =
               json_response(conn, 200)

      assert Jason.decode!(content["text"])["player_name"] == player.player_name
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == player.id
      assert Repo.get_by(RosterPosition, fantasy_team_id: team.id, fantasy_player_id: player.id)
      assert Repo.get!(DraftQueue, queue.id).status == :drafted

      assert [entry] = Audit.list_for_user(user.id)
      assert entry.source == "mcp"
      assert entry.action == "draft_pick.draft_player"
      assert entry.outcome == "success"
      assert entry.resource_id == pick.id
    end

    test "an admin can draft with another team's pick", %{conn: conn} do
      %{player: player, pick: pick} = setup_draft_data()
      admin = insert(:user, admin: true)

      conn =
        call_tool(conn, admin, "draft_player", %{
          draft_pick_id: pick.id,
          fantasy_player_id: player.id
        })

      assert %{"result" => %{"isError" => false}} = json_response(conn, 200)
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == player.id
    end

    test "a non-owner cannot draft with someone else's pick", %{conn: conn} do
      %{player: player, pick: pick} = setup_draft_data()
      stranger = insert(:user)

      conn =
        call_tool(conn, stranger, "draft_player", %{
          draft_pick_id: pick.id,
          fantasy_player_id: player.id
        })

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "not authorized"
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == nil

      assert [entry] = Audit.list_for_user(stranger.id)
      assert entry.outcome == "denied"
    end

    test "drafting is refused when the league's draft picks are locked", %{conn: conn} do
      %{team: team, player: player, pick: pick} = setup_draft_data(draft_picks_locked?: true)
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        call_tool(conn, user, "draft_player", %{
          draft_pick_id: pick.id,
          fantasy_player_id: player.id
        })

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "locked"
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == nil
    end

    test "an unavailable player surfaces a validation tool result", %{conn: conn} do
      %{league: league, team: team, player: player, pick: pick} = setup_draft_data()
      other_team = insert(:fantasy_team, fantasy_league: league)

      insert(:draft_pick,
        draft_position: 1.02,
        fantasy_team: other_team,
        fantasy_league: league,
        fantasy_player: player
      )

      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        call_tool(conn, user, "draft_player", %{
          draft_pick_id: pick.id,
          fantasy_player_id: player.id
        })

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "Validation failed"
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == nil
    end

    test "omitting the player surfaces a validation tool result, not a crash", %{conn: conn} do
      %{team: team, pick: pick} = setup_draft_data()
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn = call_tool(conn, user, "draft_player", %{draft_pick_id: pick.id})

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "Validation failed"
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == nil
    end

    test "a player that doesn't exist surfaces a validation result, not a crash", %{conn: conn} do
      %{team: team, pick: pick} = setup_draft_data()
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        call_tool(conn, user, "draft_player", %{
          draft_pick_id: pick.id,
          fantasy_player_id: 999_999
        })

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "Validation failed"
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == nil
    end

    test "a pick with no team assigned is refused, not a crash", %{conn: conn} do
      league = insert(:fantasy_league)
      player = insert(:fantasy_player)
      pick = insert(:draft_pick, draft_position: 1.01, fantasy_league: league, fantasy_team: nil)
      admin = insert(:user, admin: true)

      conn =
        call_tool(conn, admin, "draft_player", %{
          draft_pick_id: pick.id,
          fantasy_player_id: player.id
        })

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "Validation failed"
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == nil
    end

    test "a missing draft pick returns a not-found tool result", %{conn: conn} do
      user = insert(:user)

      conn = call_tool(conn, user, "draft_player", %{draft_pick_id: 0, fantasy_player_id: 1})

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "Not found"
    end
  end

  describe "tools/call update_draft_pick" do
    test "an admin can correct a pick's fields", %{conn: conn} do
      %{league: league, pick: pick} = setup_draft_data()
      other_team = insert(:fantasy_team, fantasy_league: league)
      admin = insert(:user, admin: true)

      conn =
        call_tool(conn, admin, "update_draft_pick", %{
          draft_pick_id: pick.id,
          fantasy_team_id: other_team.id,
          draft_position: 2.05,
          is_keeper: true
        })

      assert %{"result" => %{"isError" => false, "content" => [content]}} =
               json_response(conn, 200)

      assert Jason.decode!(content["text"])["is_keeper"] == true

      updated_pick = Repo.get!(DraftPick, pick.id)
      assert updated_pick.fantasy_team_id == other_team.id
      assert updated_pick.draft_position == 2.05
      assert updated_pick.is_keeper == true

      assert [entry] = Audit.list_for_user(admin.id)
      assert entry.action == "draft_pick.update"
      assert entry.source == "mcp"
      assert entry.outcome == "success"
    end

    test "an admin can update a pick in a locked league", %{conn: conn} do
      %{pick: pick} = setup_draft_data(draft_picks_locked?: true)
      admin = insert(:user, admin: true)

      conn =
        call_tool(conn, admin, "update_draft_pick", %{draft_pick_id: pick.id, is_keeper: true})

      assert %{"result" => %{"isError" => false}} = json_response(conn, 200)
      assert Repo.get!(DraftPick, pick.id).is_keeper == true
    end

    test "an owner cannot update their own pick's fields", %{conn: conn} do
      %{team: team, pick: pick} = setup_draft_data()
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)

      conn =
        call_tool(conn, user, "update_draft_pick", %{draft_pick_id: pick.id, is_keeper: true})

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "not authorized"
      assert Repo.get!(DraftPick, pick.id).is_keeper == false

      assert [entry] = Audit.list_for_user(user.id)
      assert entry.outcome == "denied"
    end

    test "the drafted player cannot be changed", %{conn: conn} do
      %{league: league, team: team, player: player} = setup_draft_data()
      other_player = insert(:fantasy_player)

      pick =
        insert(:draft_pick,
          draft_position: 1.01,
          fantasy_league: league,
          fantasy_team: team,
          fantasy_player: player
        )

      admin = insert(:user, admin: true)

      conn =
        call_tool(conn, admin, "update_draft_pick", %{
          draft_pick_id: pick.id,
          fantasy_player_id: other_player.id
        })

      assert %{"result" => %{"isError" => false}} = json_response(conn, 200)
      assert Repo.get!(DraftPick, pick.id).fantasy_player_id == player.id
    end

    test "clearing the team is refused", %{conn: conn} do
      %{pick: pick} = setup_draft_data()
      admin = insert(:user, admin: true)

      conn =
        call_tool(conn, admin, "update_draft_pick", %{
          draft_pick_id: pick.id,
          fantasy_team_id: nil
        })

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "Validation failed"
      refute is_nil(Repo.get!(DraftPick, pick.id).fantasy_team_id)
    end

    test "a team from another league is refused", %{conn: conn} do
      %{team: team, pick: pick} = setup_draft_data()
      other_league_team = insert(:fantasy_team, fantasy_league: insert(:fantasy_league))
      admin = insert(:user, admin: true)

      conn =
        call_tool(conn, admin, "update_draft_pick", %{
          draft_pick_id: pick.id,
          fantasy_team_id: other_league_team.id
        })

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "must belong to the pick's league"
      assert Repo.get!(DraftPick, pick.id).fantasy_team_id == team.id
    end

    test "a team that doesn't exist is refused, not a crash", %{conn: conn} do
      %{team: team, pick: pick} = setup_draft_data()
      admin = insert(:user, admin: true)

      conn =
        call_tool(conn, admin, "update_draft_pick", %{
          draft_pick_id: pick.id,
          fantasy_team_id: 999_999
        })

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "does not exist"
      assert Repo.get!(DraftPick, pick.id).fantasy_team_id == team.id
    end

    test "the league cannot be reassigned", %{conn: conn} do
      %{league: league, pick: pick} = setup_draft_data()
      other_league = insert(:fantasy_league)
      admin = insert(:user, admin: true)

      conn =
        call_tool(conn, admin, "update_draft_pick", %{
          draft_pick_id: pick.id,
          fantasy_league_id: other_league.id
        })

      assert %{"result" => %{"isError" => false}} = json_response(conn, 200)
      assert Repo.get!(DraftPick, pick.id).fantasy_league_id == league.id
    end
  end

  describe "league read tools respect private-league access" do
    test "a non-member cannot read a private league's waivers", %{conn: conn} do
      league = insert(:fantasy_league, private?: true)
      outsider = insert(:user)

      conn = call_tool(conn, outsider, "list_league_waivers", %{fantasy_league_id: league.id})

      assert %{"result" => %{"isError" => true, "content" => [content]}} =
               json_response(conn, 200)

      assert content["text"] =~ "not authorized"
    end

    test "a member can read a private league's waivers", %{conn: conn} do
      league = insert(:fantasy_league, private?: true)
      member = insert(:user)
      team = insert(:fantasy_team, fantasy_league: league)
      insert(:owner, fantasy_team: team, user: member)

      conn = call_tool(conn, member, "list_league_waivers", %{fantasy_league_id: league.id})

      assert %{"result" => %{"isError" => false}} = json_response(conn, 200)
    end

    test "a public league's waivers are readable by anyone", %{conn: conn} do
      league = insert(:fantasy_league, private?: false)
      user = insert(:user)

      conn = call_tool(conn, user, "list_league_waivers", %{fantasy_league_id: league.id})

      assert %{"result" => %{"isError" => false}} = json_response(conn, 200)
    end
  end
end
