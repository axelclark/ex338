defmodule Ex338.DraftPick.DraftAdmin do
  @moduledoc false

  alias Ecto.Multi
  alias Ex338.{DraftQueue, DraftPick, RosterPositions.RosterPosition}

  def draft_player(draft_pick, params) do
    Multi.new()
    |> update_draft_pick(draft_pick, params)
    |> new_roster_position(draft_pick, params)
    |> unavailable_draft_queues(draft_pick, params)
    |> drafted_draft_queues(draft_pick, params)
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
      DraftQueue.Admin.update_unavailable_from_pick(updated_draft_pick),
      [],
      returning: true
    )
  end

  defp drafted_draft_queues(multi, draft_pick, %{"fantasy_player_id" => player_id}) do
    updated_draft_pick = %{draft_pick | fantasy_player_id: player_id}

    Multi.update_all(
      multi,
      :drafted_draft_queues,
      DraftQueue.Admin.update_drafted_from_pick(updated_draft_pick),
      [],
      returning: true
    )
  end
end
