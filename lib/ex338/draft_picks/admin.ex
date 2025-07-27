defmodule Ex338.DraftPicks.Admin do
  @moduledoc false

  alias Ecto.Multi
  alias Ex338.DraftPicks.DraftPick
  alias Ex338.DraftQueues
  alias Ex338.Repo
  alias Ex338.RosterPositions.RosterPosition

  def draft_player(draft_pick, params) do
    Multi.new()
    |> update_draft_pick(draft_pick, params)
    |> new_roster_position(draft_pick, params)
    |> unavailable_draft_queues(draft_pick, params)
    |> drafted_draft_queues(draft_pick, params)
    |> maybe_update_next_keeper_drafted_at(draft_pick)
  end

  ## Helpers

  ## draft_player

  defp update_draft_pick(multi, draft_pick, params) do
    Multi.update(
      multi,
      :draft_pick,
      DraftPick.owner_changeset(draft_pick, params)
    )
  end

  defp new_roster_position(multi, draft_pick, params) do
    position_params = Map.put(params, "fantasy_team_id", draft_pick.fantasy_team_id)

    Multi.insert(
      multi,
      :roster_position,
      RosterPosition.changeset(
        %RosterPosition{position: "Unassigned", acq_method: acq_method(draft_pick)},
        position_params
      )
    )
  end

  defp acq_method(draft_pick) do
    %{draft_position: draft_position} = draft_pick
    "draft_pick:#{Float.to_string(draft_position)}"
  end

  defp unavailable_draft_queues(multi, draft_pick, %{"fantasy_player_id" => player_id}) do
    updated_draft_pick = %{draft_pick | fantasy_player_id: player_id}

    Multi.update_all(
      multi,
      :unavailable_draft_queues,
      DraftQueues.Admin.update_unavailable_from_pick(updated_draft_pick),
      [],
      returning: true
    )
  end

  defp drafted_draft_queues(multi, draft_pick, %{"fantasy_player_id" => player_id}) do
    updated_draft_pick = %{draft_pick | fantasy_player_id: player_id}

    Multi.update_all(
      multi,
      :drafted_draft_queues,
      DraftQueues.Admin.update_drafted_from_pick(updated_draft_pick),
      [],
      returning: true
    )
  end

  defp maybe_update_next_keeper_drafted_at(multi, draft_pick) do
    update_consecutive_keepers(multi, draft_pick.fantasy_league_id, draft_pick.draft_position, 0)
  end

  defp update_consecutive_keepers(multi, league_id, position, index) do
    case DraftPick
         |> DraftPick.next_pick_after_position(league_id, position)
         |> Repo.one() do
      %DraftPick{fantasy_player_id: player_id, is_keeper: true, draft_position: next_position} =
          next_pick
      when not is_nil(player_id) ->
        now = DateTime.truncate(DateTime.utc_now(), :second)

        multi
        |> Multi.update(
          :"next_keeper_drafted_at_#{index}",
          DraftPick.changeset(next_pick, %{drafted_at: now})
        )
        |> update_consecutive_keepers(league_id, next_position, index + 1)

      _ ->
        multi
    end
  end
end
