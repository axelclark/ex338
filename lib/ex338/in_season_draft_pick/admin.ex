defmodule Ex338.InSeasonDraftPick.Admin do
  @moduledoc false

  alias Ex338.{InSeasonDraftPick, RosterPosition, DraftQueue}
  alias Ecto.Multi

  def generate_picks(roster_positions, championship_id) do
    Enum.reduce(roster_positions, Multi.new(), fn position, multi ->
      create_pick_from_position(multi, position, championship_id)
    end)
  end

  def update(draft_pick, params) do
    Multi.new()
    |> update_pick(draft_pick, params)
    |> update_position(draft_pick)
    |> new_position(draft_pick, params)
    |> unavailable_draft_queues(draft_pick, params)
    |> drafted_draft_queues(draft_pick, params)
  end

  ## Helpers

  ## generate_picks

  defp create_pick_from_position(multi, roster_position, champ_id) do
    pos_num = position_from_name(roster_position.fantasy_player.player_name)

    attrs = %{
      championship_id: champ_id,
      draft_pick_asset_id: roster_position.id,
      fantasy_league_id: roster_position.fantasy_team.fantasy_league_id,
      position: pos_num
    }

    multi_name = create_multi_name(pos_num)
    changeset = InSeasonDraftPick.changeset(%InSeasonDraftPick{}, attrs)
    Multi.insert(multi, multi_name, changeset)
  end

  defp position_from_name("KD Pick #" <> position) do
    String.to_integer(position)
  end

  defp position_from_name("LLWS Pick #" <> position) do
    String.to_integer(position)
  end

  defp position_from_name(player_name) do
    String.to_atom("name_error_#{player_name}")
  end

  defp create_multi_name(pos_num) do
    String.to_atom("new_pick_#{pos_num}")
  end

  ## update

  defp update_pick(multi, draft_pick, params) do
    Multi.update(multi, :update_pick, InSeasonDraftPick.owner_changeset(draft_pick, params))
  end

  defp update_position(multi, draft_pick) do
    params = %{
      "released_at" => DateTime.utc_now(),
      "status" => "drafted_pick"
    }

    Multi.update(
      multi,
      :update_position,
      RosterPosition.changeset(draft_pick.draft_pick_asset, params)
    )
  end

  defp new_position(multi, draft_pick, %{"drafted_player_id" => player_id}) do
    params = %{
      "fantasy_team_id" => draft_pick.draft_pick_asset.fantasy_team_id,
      "fantasy_player_id" => player_id,
      "position" => draft_pick.draft_pick_asset.position,
      "active_at" => DateTime.utc_now(),
      "acq_method" => acq_method(draft_pick),
      "status" => "active"
    }

    Multi.insert(multi, :new_position, RosterPosition.changeset(%RosterPosition{}, params))
  end

  defp acq_method(draft_pick) do
    %{position: position, draft_pick_asset: %{fantasy_player: %{sports_league: sport}}} =
      draft_pick

    "#{sport.abbrev} Draft:#{Integer.to_string(position)}"
  end

  defp unavailable_draft_queues(multi, draft_pick, %{"drafted_player_id" => player_id}) do
    updated_draft_pick = %{draft_pick | drafted_player_id: player_id}

    Multi.update_all(
      multi,
      :unavailable_draft_queues,
      DraftQueue.Admin.update_unavailable_from_pick(updated_draft_pick),
      [],
      returning: true
    )
  end

  defp drafted_draft_queues(multi, draft_pick, %{"drafted_player_id" => player_id}) do
    updated_draft_pick = %{draft_pick | drafted_player_id: player_id}

    Multi.update_all(
      multi,
      :drafted_draft_queues,
      DraftQueue.Admin.update_drafted_from_pick(updated_draft_pick),
      [],
      returning: true
    )
  end
end
