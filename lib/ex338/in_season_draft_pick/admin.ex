defmodule Ex338.InSeasonDraftPick.Admin do
  @moduledoc false

  alias Ex338.{InSeasonDraftPick, RosterPosition}
  alias Ecto.Multi

  def generate_picks(roster_positions, championship_id) do
    Enum.reduce roster_positions, Multi.new(), fn(position, multi) ->
      create_pick_from_position(multi, position, championship_id)
    end
  end

  defp create_pick_from_position(multi, roster_position, champ_id) do
    pos_num = position_from_name(roster_position.fantasy_player.player_name)
    attrs = %{
      draft_pick_asset_id: roster_position.id,
      position: pos_num,
      championship_id: champ_id
    }
    multi_name = create_multi_name(pos_num)
    changeset = InSeasonDraftPick.changeset(%InSeasonDraftPick{}, attrs)
    Multi.insert(multi, multi_name, changeset)
  end

  defp position_from_name("KD Pick #" <> position) do
    String.to_integer(position)
  end

  defp position_from_name(player_name) do
    String.to_atom("name_error_#{player_name}")
  end

  defp create_multi_name(pos_num) do
    String.to_atom("new_pick_#{pos_num}")
  end

  def update(draft_pick, params) do
    Multi.new
    |> update_pick(draft_pick, params)
    |> update_position(draft_pick)
    |> new_position(draft_pick, params)
  end

  defp update_pick(multi, draft_pick, params) do
    Multi.update(multi, :update_pick,
      InSeasonDraftPick.owner_changeset(draft_pick, params))
  end

  defp update_position(multi, draft_pick) do
    params = %{
      "released_at" => Ecto.DateTime.utc(),
      "status" => "drafted_pick"
    }

    Multi.update(multi, :update_position,
      RosterPosition.changeset(draft_pick.draft_pick_asset, params))
  end

  defp new_position(multi, draft_pick, %{"drafted_player_id" => player_id}) do
    params = %{
      "fantasy_team_id" => draft_pick.draft_pick_asset.fantasy_team_id,
      "fantasy_player_id" => player_id,
      "position" => draft_pick.draft_pick_asset.position,
      "active_at" => Ecto.DateTime.utc(),
      "status" => "active"
    }

    Multi.insert(multi, :new_position,
      RosterPosition.changeset(%RosterPosition{}, params))
  end
end
