defmodule Ex338Web.ApiActions do
  @moduledoc """
  Shared authorized write actions for the REST API and MCP server.

  Each function runs the authorization check (via `Ex338.Abilities`), delegates
  to the domain context, sends any notifications, and records an audit entry — so
  both transports share one implementation and one audit trail. The only
  difference between an API call and an MCP call is the `source` string ("api" vs
  "mcp") the caller passes.

  `actor` is `%{user: %Ex338.Accounts.User{}, api_token: %Ex338.Accounts.UserToken{} | nil}`.
  """
  alias Ex338.Audit
  alias Ex338.DraftQueues
  alias Ex338.FantasyTeams
  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.InjuredReserves
  alias Ex338.Waivers

  @doc """
  Creates a waiver for a fantasy team. Returns `{:ok, %Waiver{}}`,
  `{:error, :not_found}`, `{:error, :forbidden}`, or `{:error, %Ecto.Changeset{}}`.
  """
  def create_waiver(actor, source, team_id, params) do
    team = FantasyTeams.get_team_with_owners(team_id)
    result = do_create_waiver(actor.user, team, params)

    audit(actor, source, "waiver.create", "Waiver", result, team, %{
      fantasy_team_id: team_id,
      params: params
    })

    result
  end

  defp do_create_waiver(_user, nil, _params), do: {:error, :not_found}

  defp do_create_waiver(user, %FantasyTeam{} = team, params) do
    if Canada.Can.can?(user, :create, team) do
      case Waivers.create_waiver(team, waiver_params(params)) do
        {:ok, waiver} ->
          Ex338Web.WaiverNotifier.waiver_submitted(waiver)
          {:ok, Waivers.find_waiver(waiver.id)}

        {:error, %Ecto.Changeset{}} = error ->
          error
      end
    else
      {:error, :forbidden}
    end
  end

  # Only these fields may be set by an API/MCP client. The team comes from the
  # authorized team (via build_assoc), never the request body, so a client can't
  # write to a team they don't own by supplying a different fantasy_team_id.
  defp waiver_params(params) do
    Map.take(params, ["add_fantasy_player_id", "drop_fantasy_player_id"])
  end

  @doc """
  Creates an injured reserve request for a fantasy team. Returns
  `{:ok, %InjuredReserve{}}`, `{:error, :not_found}`, `{:error, :forbidden}`, or
  `{:error, %Ecto.Changeset{}}`.
  """
  def create_injured_reserve(actor, source, team_id, params) do
    team = FantasyTeams.get_team_with_owners(team_id)
    result = do_create_injured_reserve(actor.user, team, params)

    audit(actor, source, "injured_reserve.create", "InjuredReserve", result, team, %{
      fantasy_team_id: team_id,
      params: params
    })

    result
  end

  defp do_create_injured_reserve(_user, nil, _params), do: {:error, :not_found}

  defp do_create_injured_reserve(user, %FantasyTeam{} = team, params) do
    if Canada.Can.can?(user, :create, team) do
      case InjuredReserves.create_injured_reserve(team, ir_params(params)) do
        {:ok, injured_reserve} -> {:ok, InjuredReserves.get_ir!(injured_reserve.id)}
        {:error, %Ecto.Changeset{}} = error -> error
      end
    else
      {:error, :forbidden}
    end
  end

  # Deliberately excludes :status — an owner-created IR must start as "submitted"
  # (the schema default); approving/rejecting/returning is a commissioner action.
  defp ir_params(params) do
    Map.take(params, ["injured_player_id", "replacement_player_id"])
  end

  @doc """
  Adds a player to a fantasy team's draft queue. Returns `{:ok, %DraftQueue{}}`,
  `{:error, :not_found}`, `{:error, :forbidden}`, or `{:error, %Ecto.Changeset{}}`.
  """
  def create_draft_queue(actor, source, team_id, params) do
    team = FantasyTeams.get_team_with_owners(team_id)
    result = do_create_draft_queue(actor.user, team, params)

    audit(actor, source, "draft_queue.create", "DraftQueue", result, team, %{
      fantasy_team_id: team_id,
      params: params
    })

    result
  end

  defp do_create_draft_queue(_user, nil, _params), do: {:error, :not_found}

  defp do_create_draft_queue(user, %FantasyTeam{} = team, params) do
    if Canada.Can.can?(user, :create, team) do
      case DraftQueues.create_draft_queue(draft_queue_params(params, team)) do
        {:ok, draft_queue} -> {:ok, DraftQueues.get_draft_queue!(draft_queue.id)}
        {:error, %Ecto.Changeset{}} = error -> error
      end
    else
      {:error, :forbidden}
    end
  end

  # Client may only pick the player; the team is forced to the authorized team,
  # and :order/:status are left to the context (auto-ordered, default "pending").
  defp draft_queue_params(params, team) do
    params
    |> Map.take(["fantasy_player_id"])
    |> Map.put("fantasy_team_id", team.id)
  end

  defp audit(actor, source, action, resource_type, result, team, metadata) do
    Audit.log(%{
      user_id: actor.user.id,
      api_token_id: token_id(actor),
      fantasy_league_id: team && team.fantasy_league_id,
      source: source,
      action: action,
      resource_type: resource_type,
      resource_id: resource_id(result),
      outcome: Audit.outcome_for(result),
      metadata: Map.put(metadata, :token_name, token_name(actor))
    })
  end

  defp resource_id({:ok, %{id: id}}), do: id
  defp resource_id(_), do: nil

  defp token_id(%{api_token: %{id: id}}), do: id
  defp token_id(_), do: nil

  defp token_name(%{api_token: %{sent_to: name}}), do: name
  defp token_name(_), do: nil
end
