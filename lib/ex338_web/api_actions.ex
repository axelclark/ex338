defmodule Ex338Web.ApiActions do
  @moduledoc """
  Shared authorized write actions for the REST API and MCP server.

  Each function runs the authorization check (via `Ex338.Abilities`), delegates
  to the domain context, sends any notifications, and records an audit entry — so
  both transports share one implementation and one audit trail. The only
  difference between an API call and an MCP call is the `source` string ("api" vs
  "mcp") the caller passes.

  Most actions are owner-or-admin, mirroring what the HTML app allows. A few are
  commissioner corrections that bypass the domain rules to fix the record
  (`update_draft_pick/4`) and check `user.admin` directly.

  `actor` is `%{user: %Ex338.Accounts.User{}, api_token: %Ex338.Accounts.UserToken{} | nil}`.
  """
  alias Ex338.Audit
  alias Ex338.AutoDraft
  alias Ex338.DraftPicks
  alias Ex338.DraftPicks.DraftPick
  alias Ex338.DraftQueues
  alias Ex338.FantasyTeams
  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.InjuredReserves
  alias Ex338.Waivers

  # Matches the HTML draft controller: give owners a moment to see their pick land
  # before autodraft starts filling in queued picks behind them.
  @autodraft_delay 1000 * 10

  @doc """
  Creates a waiver for a fantasy team. Returns `{:ok, %Waiver{}}`,
  `{:error, :not_found}`, `{:error, :forbidden}`, or `{:error, %Ecto.Changeset{}}`.
  """
  def create_waiver(actor, source, team_id, params) do
    team = FantasyTeams.get_team_with_owners(team_id)
    result = do_create_waiver(actor.user, team, params)

    audit(actor, source, "waiver.create", "Waiver", result, league_id(team), %{
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

    audit(actor, source, "injured_reserve.create", "InjuredReserve", result, league_id(team), %{
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

    audit(actor, source, "draft_queue.create", "DraftQueue", result, league_id(team), %{
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

  @doc """
  Drafts a player with a draft pick — the same action an owner takes on the draft
  page, with the same validations (your pick must be up, flex spots, player
  availability), roster position, draft queue updates, email, and autodraft
  follow-on. Owners may use their own team's picks; admins any pick.

  Returns `{:ok, %DraftPick{}}`, `{:error, :not_found}`, `{:error, :forbidden}`,
  `{:error, :draft_picks_locked}`, or `{:error, %Ecto.Changeset{}}`.
  """
  def draft_player(actor, source, draft_pick_id, params) do
    draft_pick = DraftPicks.get_draft_pick(draft_pick_id)
    result = do_draft_player(actor.user, draft_pick, params)

    audit(actor, source, "draft_pick.draft_player", "DraftPick", result, league_id(draft_pick), %{
      draft_pick_id: draft_pick_id,
      params: params
    })

    result
  end

  defp do_draft_player(_user, nil, _params), do: {:error, :not_found}

  defp do_draft_player(user, %DraftPick{} = draft_pick, params) do
    cond do
      not can_update?(user, draft_pick) -> {:error, :forbidden}
      draft_pick.fantasy_league.draft_picks_locked? -> {:error, :draft_picks_locked}
      is_nil(draft_pick.fantasy_team_id) -> {:error, missing_team_changeset(draft_pick)}
      true -> submit_draft_pick(draft_pick, params)
    end
  end

  # `fantasy_team_id` is nullable, and drafting needs a team to hold the roster
  # position and to scope the draft-queue updates. Report it instead of letting the
  # queue update raise on the missing team.
  defp missing_team_changeset(draft_pick) do
    draft_pick
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.add_error(:fantasy_team_id, "can't be blank", validation: :required)
    |> Map.put(:action, :update)
  end

  defp submit_draft_pick(draft_pick, params) do
    case draft_player_params(params) do
      %{"fantasy_player_id" => nil} -> {:error, blank_player_changeset(draft_pick)}
      draft_player_params -> do_submit_draft_pick(draft_pick, draft_player_params)
    end
  end

  # `DraftPicks.draft_player/2` builds its draft-queue updates from the player id,
  # so it can't be handed a nil. Report the omission as the validation error the
  # changeset would have produced.
  defp blank_player_changeset(draft_pick) do
    draft_pick
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.add_error(:fantasy_player_id, "can't be blank", validation: :required)
    |> Map.put(:action, :update)
  end

  defp do_submit_draft_pick(draft_pick, params) do
    case DraftPicks.draft_player(draft_pick, params) do
      {:ok, %{draft_pick: drafted_pick}} ->
        Ex338Web.DraftPickNotifier.send_update(drafted_pick)
        DraftQueues.reorder_for_league(drafted_pick.fantasy_league_id)

        Task.start(fn ->
          AutoDraft.make_picks_from_queues(drafted_pick, [], @autodraft_delay)
        end)

        {:ok, DraftPicks.get_draft_pick!(drafted_pick.id)}

      {:error, _failed_operation, %Ecto.Changeset{} = changeset, _changes} ->
        {:error, changeset}
    end
  end

  # The player is the only thing a client picks. Everything else about the pick
  # (which team, which league, when) comes from the pick being drafted with.
  defp draft_player_params(params) do
    %{"fantasy_player_id" => params["fantasy_player_id"]}
  end

  @doc """
  Corrects a draft pick's metadata (order, owning team, keeper flag) — the
  commissioner path, so it is admin-only.

  Which fields may be corrected, and the invariants they have to hold, live in
  `Ex338.DraftPicks.DraftPick.admin_changeset/2`; notably the drafted player is not
  among them, because this path doesn't touch roster positions. Returns
  `{:ok, %DraftPick{}}`, `{:error, :not_found}`, `{:error, :forbidden}`, or
  `{:error, %Ecto.Changeset{}}`.
  """
  def update_draft_pick(actor, source, draft_pick_id, params) do
    draft_pick = DraftPicks.get_draft_pick(draft_pick_id)
    result = do_update_draft_pick(actor.user, draft_pick, params)

    audit(actor, source, "draft_pick.update", "DraftPick", result, league_id(draft_pick), %{
      draft_pick_id: draft_pick_id,
      params: params
    })

    result
  end

  defp do_update_draft_pick(_user, nil, _params), do: {:error, :not_found}

  defp do_update_draft_pick(%{admin: true}, %DraftPick{} = draft_pick, params) do
    case DraftPicks.update_draft_pick(draft_pick, params) do
      {:ok, updated_draft_pick} -> {:ok, DraftPicks.get_draft_pick!(updated_draft_pick.id)}
      {:error, %Ecto.Changeset{}} = error -> error
    end
  end

  defp do_update_draft_pick(_user, _draft_pick, _params), do: {:error, :forbidden}

  # Admins pass via `Ex338.Abilities`; owners are checked against the pick's team,
  # so a pick with no team assigned is admin-only.
  defp can_update?(user, %DraftPick{fantasy_team: %FantasyTeam{}} = draft_pick) do
    Canada.Can.can?(user, :update, draft_pick)
  end

  defp can_update?(user, %DraftPick{}), do: user.admin

  defp league_id(%{fantasy_league_id: league_id}), do: league_id
  defp league_id(_resource), do: nil

  defp audit(actor, source, action, resource_type, result, fantasy_league_id, metadata) do
    Audit.log(%{
      user_id: actor.user.id,
      api_token_id: token_id(actor),
      fantasy_league_id: fantasy_league_id,
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
