defmodule Ex338Web.Api.V1.Mcp.Tools do
  @moduledoc """
  MCP tool definitions and execution.

  Each tool is a thin wrapper over a context function, authorized with the same
  `Ex338.Abilities` rules as the REST API: admins may act on anything, owners on
  their own teams. `call/3` receives the already-authenticated user (established
  by `Ex338Web.Plugs.ApiAuth`) and returns a tagged result the MCP controller
  maps onto the JSON-RPC/tool-result envelope.
  """
  alias Ex338.FantasyTeams
  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.Waivers

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
      }
    ]
  end

  @doc """
  Executes a tool. Returns `{:ok, data}` or a tagged error:
  `{:error, :not_found | :forbidden | :unknown_tool}`,
  `{:error, {:invalid_params, message}}`, or `{:error, {:changeset, changeset}}`.
  """
  def call("whoami", _args, user) do
    {:ok, %{id: user.id, name: user.name, email: user.email, admin: user.admin}}
  end

  def call("list_league_waivers", %{"fantasy_league_id" => league_id}, _user) do
    waivers = Waivers.get_all_waivers(league_id)
    {:ok, %{waivers: Enum.map(waivers, &waiver_summary/1)}}
  end

  def call("list_league_waivers", _args, _user) do
    {:error, {:invalid_params, "fantasy_league_id is required"}}
  end

  def call("create_waiver", %{"fantasy_team_id" => team_id} = args, user) do
    with %FantasyTeam{} = team <- FantasyTeams.get_team_with_owners(team_id),
         true <- Canada.Can.can?(user, :create, team) || {:error, :forbidden},
         {:ok, waiver} <- Waivers.create_waiver(team, waiver_params(args)) do
      Ex338Web.WaiverNotifier.waiver_submitted(waiver)
      {:ok, waiver_summary(Waivers.find_waiver(waiver.id))}
    else
      nil -> {:error, :not_found}
      {:error, :forbidden} -> {:error, :forbidden}
      {:error, %Ecto.Changeset{} = changeset} -> {:error, {:changeset, changeset}}
    end
  end

  def call("create_waiver", _args, _user) do
    {:error, {:invalid_params, "fantasy_team_id is required"}}
  end

  def call(_name, _args, _user), do: {:error, :unknown_tool}

  defp waiver_params(args) do
    Map.take(args, ["add_fantasy_player_id", "drop_fantasy_player_id"])
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
end
