defmodule Ex338Web.Api.V1.Mcp.Tools do
  @moduledoc """
  MCP tool definitions and execution.

  Each tool is a thin wrapper over a context function. Write tools are authorized
  with the same `Ex338.Abilities` rules as the REST API (admins act on anything,
  owners on their own teams) via `Ex338Web.ApiActions`; league read tools are
  scoped by `FantasyLeagues.can_access_league?/2` so private leagues stay private.
  `call/3` receives the already-authenticated `actor` (established by
  `Ex338Web.Plugs.ApiAuth`) and returns a tagged result the MCP controller maps
  onto the JSON-RPC/tool-result envelope.
  """
  alias Ex338.DraftQueues
  alias Ex338.FantasyLeagues
  alias Ex338.FantasyTeams
  alias Ex338.InjuredReserves
  alias Ex338.Waivers
  alias Ex338Web.ApiActions

  @doc """
  The list of tools advertised via `tools/list`, with JSON Schema for arguments.
  """
  def list do
    [
      %{
        name: "whoami",
        description:
          "Return the authenticated user's identity and whether they have admin scope.",
        inputSchema: %{type: "object", properties: %{}, additionalProperties: false}
      },
      %{
        name: "list_league_waivers",
        description: "List all waivers for a fantasy league.",
        inputSchema: %{
          type: "object",
          properties: %{
            fantasy_league_id: %{type: "integer", description: "The fantasy league id"}
          },
          required: ["fantasy_league_id"],
          additionalProperties: false
        }
      },
      %{
        name: "create_waiver",
        description:
          "Submit a waiver claim (add and/or drop a player) for a fantasy team. " <>
            "Owners may act on their own team; admins on any team.",
        inputSchema: %{
          type: "object",
          properties: %{
            fantasy_team_id: %{type: "integer", description: "The fantasy team id"},
            add_fantasy_player_id: %{type: "integer", description: "Player to add (optional)"},
            drop_fantasy_player_id: %{type: "integer", description: "Player to drop (optional)"}
          },
          required: ["fantasy_team_id"],
          additionalProperties: false
        }
      },
      %{
        name: "list_league_injured_reserves",
        description: "List all injured reserve requests for a fantasy league.",
        inputSchema: %{
          type: "object",
          properties: %{
            fantasy_league_id: %{type: "integer", description: "The fantasy league id"}
          },
          required: ["fantasy_league_id"],
          additionalProperties: false
        }
      },
      %{
        name: "create_injured_reserve",
        description:
          "Submit an injured reserve request (move an injured player to IR and add a " <>
            "replacement) for a fantasy team. Owners may act on their own team; admins on any team.",
        inputSchema: %{
          type: "object",
          properties: %{
            fantasy_team_id: %{type: "integer", description: "The fantasy team id"},
            injured_player_id: %{type: "integer", description: "The injured player to move to IR"},
            replacement_player_id: %{
              type: "integer",
              description: "The replacement player to add"
            }
          },
          required: ["fantasy_team_id", "injured_player_id", "replacement_player_id"],
          additionalProperties: false
        }
      },
      %{
        name: "list_team_draft_queues",
        description:
          "List a fantasy team's pending draft queue (its ordered wishlist). Visible only " <>
            "to the team's owners and admins.",
        inputSchema: %{
          type: "object",
          properties: %{fantasy_team_id: %{type: "integer", description: "The fantasy team id"}},
          required: ["fantasy_team_id"],
          additionalProperties: false
        }
      },
      %{
        name: "create_draft_queue",
        description:
          "Add a player to a fantasy team's draft queue (wishlist). Owners may act on their " <>
            "own team; admins on any team.",
        inputSchema: %{
          type: "object",
          properties: %{
            fantasy_team_id: %{type: "integer", description: "The fantasy team id"},
            fantasy_player_id: %{type: "integer", description: "The player to queue"}
          },
          required: ["fantasy_team_id", "fantasy_player_id"],
          additionalProperties: false
        }
      }
    ]
  end

  @doc """
  Executes a tool for the given `actor` (`%{user:, api_token:}`). Returns
  `{:ok, data}` or a tagged error: `{:error, :not_found | :forbidden | :unknown_tool}`,
  `{:error, {:invalid_params, message}}`, or `{:error, %Ecto.Changeset{}}`.
  """
  def call("whoami", _args, %{user: user}) do
    {:ok, %{id: user.id, name: user.name, email: user.email, admin: user.admin}}
  end

  def call("list_league_waivers", %{"fantasy_league_id" => league_id}, %{user: user}) do
    with_league_access(league_id, user, fn ->
      waivers = Waivers.get_all_waivers(league_id)
      {:ok, %{waivers: Enum.map(waivers, &waiver_summary/1)}}
    end)
  end

  def call("list_league_waivers", _args, _actor) do
    {:error, {:invalid_params, "fantasy_league_id is required"}}
  end

  def call("create_waiver", %{"fantasy_team_id" => team_id} = args, actor) do
    case ApiActions.create_waiver(actor, "mcp", team_id, waiver_params(args)) do
      {:ok, waiver} -> {:ok, waiver_summary(waiver)}
      error -> error
    end
  end

  def call("create_waiver", _args, _actor) do
    {:error, {:invalid_params, "fantasy_team_id is required"}}
  end

  def call("list_league_injured_reserves", %{"fantasy_league_id" => league_id}, %{user: user}) do
    with_league_access(league_id, user, fn ->
      irs = InjuredReserves.list_irs_for_league(league_id)
      {:ok, %{injured_reserves: Enum.map(irs, &ir_summary/1)}}
    end)
  end

  def call("list_league_injured_reserves", _args, _actor) do
    {:error, {:invalid_params, "fantasy_league_id is required"}}
  end

  def call("create_injured_reserve", %{"fantasy_team_id" => team_id} = args, actor) do
    case ApiActions.create_injured_reserve(actor, "mcp", team_id, ir_params(args)) do
      {:ok, injured_reserve} -> {:ok, ir_summary(injured_reserve)}
      error -> error
    end
  end

  def call("create_injured_reserve", _args, _actor) do
    {:error, {:invalid_params, "fantasy_team_id is required"}}
  end

  def call("list_team_draft_queues", %{"fantasy_team_id" => team_id}, %{user: user}) do
    with_team_access(team_id, user, fn ->
      queues = DraftQueues.list_team_queues(team_id)
      {:ok, %{draft_queues: Enum.map(queues, &draft_queue_summary/1)}}
    end)
  end

  def call("list_team_draft_queues", _args, _actor) do
    {:error, {:invalid_params, "fantasy_team_id is required"}}
  end

  def call("create_draft_queue", %{"fantasy_team_id" => team_id} = args, actor) do
    case ApiActions.create_draft_queue(actor, "mcp", team_id, draft_queue_params(args)) do
      {:ok, draft_queue} -> {:ok, draft_queue_summary(draft_queue)}
      error -> error
    end
  end

  def call("create_draft_queue", _args, _actor) do
    {:error, {:invalid_params, "fantasy_team_id is required"}}
  end

  def call(_name, _args, _actor), do: {:error, :unknown_tool}

  # Scopes a league read to users who may see the league (public leagues, admins,
  # or members of a private league).
  defp with_league_access(league_id, user, fun) do
    case FantasyLeagues.get(league_id) do
      nil ->
        {:error, :not_found}

      league ->
        if FantasyLeagues.can_access_league?(league, user), do: fun.(), else: {:error, :forbidden}
    end
  end

  # Scopes a team read to the team's owners and admins (e.g. a private draft queue).
  defp with_team_access(team_id, user, fun) do
    case FantasyTeams.get_team_with_owners(team_id) do
      nil -> {:error, :not_found}
      team -> if Canada.Can.can?(user, :edit, team), do: fun.(), else: {:error, :forbidden}
    end
  end

  defp waiver_params(args) do
    Map.take(args, ["add_fantasy_player_id", "drop_fantasy_player_id"])
  end

  defp ir_params(args) do
    Map.take(args, ["injured_player_id", "replacement_player_id", "status"])
  end

  defp draft_queue_params(args) do
    Map.take(args, ["fantasy_player_id", "order"])
  end

  defp waiver_summary(waiver) do
    %{
      id: waiver.id,
      status: waiver.status,
      fantasy_team_id: waiver.fantasy_team_id,
      add_fantasy_player_id: waiver.add_fantasy_player_id,
      drop_fantasy_player_id: waiver.drop_fantasy_player_id
    }
  end

  defp ir_summary(injured_reserve) do
    %{
      id: injured_reserve.id,
      status: injured_reserve.status,
      fantasy_team_id: injured_reserve.fantasy_team_id,
      injured_player_id: injured_reserve.injured_player_id,
      replacement_player_id: injured_reserve.replacement_player_id
    }
  end

  defp draft_queue_summary(draft_queue) do
    %{
      id: draft_queue.id,
      order: draft_queue.order,
      status: draft_queue.status,
      fantasy_team_id: draft_queue.fantasy_team_id,
      fantasy_player_id: draft_queue.fantasy_player_id
    }
  end
end
