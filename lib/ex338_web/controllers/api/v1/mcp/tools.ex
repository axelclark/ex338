defmodule Ex338Web.Api.V1.Mcp.Tools do
  @moduledoc """
  MCP tool definitions and execution.

  Each tool is a thin wrapper over a context function. Write tools are authorized
  with the same `Ex338.Abilities` rules as the REST API (admins act on anything,
  owners on their own teams) via `Ex338Web.ApiActions` — except commissioner-only
  corrections like `update_draft_pick`, which require admin; league read tools are
  scoped by `FantasyLeagues.can_access_league?/2` so private leagues stay private.
  `call/3` receives the already-authenticated `actor` (established by
  `Ex338Web.Plugs.ApiAuth`) and returns a tagged result the MCP controller maps
  onto the JSON-RPC/tool-result envelope.
  """
  alias Ex338.Accounts
  alias Ex338.DraftPicks
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
          "Return the authenticated user's identity, whether they have admin scope, and the " <>
            "fantasy teams they own with the league each team plays in. Call this first: every " <>
            "team-scoped tool needs a fantasy_team_id, and an owner may have teams in more than " <>
            "one league, so use this to map their teams to ids before acting on one.",
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
            fantasy_team_id: %{type: "integer", description: "The fantasy team id (from whoami)"},
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
            fantasy_team_id: %{type: "integer", description: "The fantasy team id (from whoami)"},
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
          properties: %{
            fantasy_team_id: %{type: "integer", description: "The fantasy team id (from whoami)"}
          },
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
            fantasy_team_id: %{type: "integer", description: "The fantasy team id (from whoami)"},
            fantasy_player_id: %{type: "integer", description: "The player to queue"}
          },
          required: ["fantasy_team_id", "fantasy_player_id"],
          additionalProperties: false
        }
      },
      %{
        name: "list_league_draft_picks",
        description:
          "List the draft board for a fantasy league: every pick in order, who owns it, who " <>
            "was drafted, and which picks are currently available to pick.",
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
        name: "draft_player",
        description:
          "Draft a player with a draft pick. Runs the same rules as the draft page: the pick " <>
            "must be up (or reachable by skipping teams over the clock), the team must have a " <>
            "flex spot for the player, and the player must not already have been drafted in " <>
            "this league. It does NOT verify the player is in the league's available pool, so " <>
            "the caller is responsible for checking the player is active for this season and " <>
            "not already owned. Also creates the roster position, updates draft queues, emails " <>
            "the league, and starts autodraft. Owners may use their own team's picks; admins any pick.",
        inputSchema: %{
          type: "object",
          properties: %{
            draft_pick_id: %{type: "integer", description: "The draft pick to use"},
            fantasy_player_id: %{type: "integer", description: "The player to draft"}
          },
          required: ["draft_pick_id", "fantasy_player_id"],
          additionalProperties: false
        }
      },
      %{
        name: "update_draft_pick",
        description:
          "Admin only. Correct a draft pick's metadata, bypassing the draft rules — for fixing " <>
            "the board (reassigning an unused pick, marking a keeper, adjusting the order). " <>
            "Only the fields you pass are changed. This writes the pick alone and does not " <>
            "touch roster positions or draft queues, which is why it cannot change who was " <>
            "drafted (use draft_player for that) and cannot move a pick to another team once " <>
            "the pick has been used. The owning team must be in the pick's own league.",
        inputSchema: %{
          type: "object",
          properties: %{
            draft_pick_id: %{type: "integer", description: "The draft pick to update"},
            fantasy_team_id: %{
              type: "integer",
              description: "Team the pick belongs to; must be in the pick's league"
            },
            draft_position: %{type: "number", description: "Position in the draft order"},
            is_keeper: %{type: "boolean", description: "Whether the pick is a keeper"},
            drafted_at: %{
              type: ["string", "null"],
              description: "ISO 8601 timestamp the pick was made; null clears it"
            }
          },
          required: ["draft_pick_id"],
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
    user = Accounts.load_user_teams(user)

    {:ok,
     %{
       id: user.id,
       name: user.name,
       email: user.email,
       admin: user.admin,
       fantasy_teams: Enum.map(user.fantasy_teams, &user_team_summary/1)
     }}
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
    case ApiActions.create_waiver(actor, "mcp", team_id, args) do
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
    case ApiActions.create_injured_reserve(actor, "mcp", team_id, args) do
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
    case ApiActions.create_draft_queue(actor, "mcp", team_id, args) do
      {:ok, draft_queue} -> {:ok, draft_queue_summary(draft_queue)}
      error -> error
    end
  end

  def call("create_draft_queue", _args, _actor) do
    {:error, {:invalid_params, "fantasy_team_id is required"}}
  end

  def call("list_league_draft_picks", %{"fantasy_league_id" => league_id}, %{user: user}) do
    with_league_access(league_id, user, fn ->
      %{draft_picks: draft_picks} = DraftPicks.get_picks_for_league(league_id)
      {:ok, %{draft_picks: Enum.map(draft_picks, &board_pick_summary/1)}}
    end)
  end

  def call("list_league_draft_picks", _args, _actor) do
    {:error, {:invalid_params, "fantasy_league_id is required"}}
  end

  def call("draft_player", %{"draft_pick_id" => pick_id} = args, actor) do
    case ApiActions.draft_player(actor, "mcp", pick_id, args) do
      {:ok, draft_pick} -> {:ok, draft_pick_summary(draft_pick)}
      error -> error
    end
  end

  def call("draft_player", _args, _actor) do
    {:error, {:invalid_params, "draft_pick_id is required"}}
  end

  def call("update_draft_pick", %{"draft_pick_id" => pick_id} = args, actor) do
    case ApiActions.update_draft_pick(actor, "mcp", pick_id, args) do
      {:ok, draft_pick} -> {:ok, draft_pick_summary(draft_pick)}
      error -> error
    end
  end

  def call("update_draft_pick", _args, _actor) do
    {:error, {:invalid_params, "draft_pick_id is required"}}
  end

  def call(_name, _args, _actor), do: {:error, :unknown_tool}

  # Scopes a league read to users who may see the league (public leagues, admins,
  # or members of a private league). Untrusted ids that aren't valid integers are
  # treated as not-found rather than raising Ecto.Query.CastError.
  defp with_league_access(league_id, user, fun) do
    with {:ok, id} <- cast_id(league_id),
         league when not is_nil(league) <- FantasyLeagues.get(id) do
      if FantasyLeagues.can_access_league?(league, user), do: fun.(), else: {:error, :forbidden}
    else
      _ -> {:error, :not_found}
    end
  end

  defp cast_id(id) when is_integer(id), do: {:ok, id}

  defp cast_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, ""} -> {:ok, int}
      _ -> :error
    end
  end

  defp cast_id(_), do: :error

  # Scopes a team read to the team's owners and admins (e.g. a private draft queue).
  defp with_team_access(team_id, user, fun) do
    case FantasyTeams.get_team_with_owners(team_id) do
      nil -> {:error, :not_found}
      team -> if Canada.Can.can?(user, :edit, team), do: fun.(), else: {:error, :forbidden}
    end
  end

  defp waiver_summary(waiver) do
    Map.merge(
      %{
        id: waiver.id,
        status: waiver.status,
        fantasy_team_id: waiver.fantasy_team_id,
        add_fantasy_player_id: waiver.add_fantasy_player_id,
        drop_fantasy_player_id: waiver.drop_fantasy_player_id
      },
      team_fields(waiver.fantasy_team)
    )
  end

  defp ir_summary(injured_reserve) do
    Map.merge(
      %{
        id: injured_reserve.id,
        status: injured_reserve.status,
        fantasy_team_id: injured_reserve.fantasy_team_id,
        injured_player_id: injured_reserve.injured_player_id,
        replacement_player_id: injured_reserve.replacement_player_id
      },
      team_fields(injured_reserve.fantasy_team)
    )
  end

  defp draft_pick_summary(draft_pick) do
    %{
      id: draft_pick.id,
      draft_position: draft_pick.draft_position,
      fantasy_league_id: draft_pick.fantasy_league_id,
      fantasy_team_id: draft_pick.fantasy_team_id,
      team_name: assoc_field(draft_pick.fantasy_team, :team_name),
      fantasy_player_id: draft_pick.fantasy_player_id,
      player_name: assoc_field(draft_pick.fantasy_player, :player_name),
      is_keeper: draft_pick.is_keeper,
      drafted_at: draft_pick.drafted_at
    }
  end

  # Adds the fields only the full board can answer — a pick's number and whether
  # it can be used right now depend on every other pick in the league.
  defp board_pick_summary(draft_pick) do
    draft_pick
    |> draft_pick_summary()
    |> Map.merge(%{
      pick_number: draft_pick.pick_number,
      available_to_pick?: draft_pick.available_to_pick?
    })
  end

  defp assoc_field(nil, _field), do: nil
  defp assoc_field(assoc, field), do: Map.get(assoc, field)

  defp draft_queue_summary(draft_queue) do
    Map.merge(
      %{
        id: draft_queue.id,
        order: draft_queue.order,
        status: draft_queue.status,
        fantasy_team_id: draft_queue.fantasy_team_id,
        fantasy_player_id: draft_queue.fantasy_player_id
      },
      team_fields(draft_queue.fantasy_team)
    )
  end

  # A bare fantasy_team_id is ambiguous for an owner with teams in more than one
  # league, so every team-scoped result names its team and the league it plays in.
  defp team_fields(fantasy_team) do
    %{
      team_name: assoc_field(fantasy_team, :team_name),
      fantasy_league_id: assoc_field(fantasy_team, :fantasy_league_id)
    }
  end

  defp user_team_summary(fantasy_team) do
    %{
      id: fantasy_team.id,
      team_name: fantasy_team.team_name,
      fantasy_league: user_league_summary(fantasy_team.fantasy_league)
    }
  end

  defp user_league_summary(%{id: id} = fantasy_league) do
    %{
      id: id,
      fantasy_league_name: fantasy_league.fantasy_league_name,
      division: fantasy_league.division,
      year: fantasy_league.year
    }
  end

  defp user_league_summary(_not_loaded), do: nil
end
