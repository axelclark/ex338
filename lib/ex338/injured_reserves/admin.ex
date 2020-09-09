defmodule Ex338.InjuredReserves.Admin do
  @moduledoc """
  Returns an `Ecto.Multi` with actions to process an approved `InjuredReserve`.
  """

  alias Ecto.Multi
  alias Ex338.{InjuredReserves.InjuredReserve, RosterPositions.RosterPosition}

  def approve_injured_reserve(injured_reserve, position) do
    Multi.new()
    |> update_injured_reserve(injured_reserve, %{"status" => "approved"})
    |> update_position_to_injured_reserve(position)
    |> create_replacement_position(injured_reserve)
  end

  def reject_injured_reserve(injured_reserve) do
    update_injured_reserve(Multi.new(), injured_reserve, %{"status" => "rejected"})
  end

  def return_injured_reserve(injured_reserve, ir_position, replacement_position) do
    Multi.new()
    |> update_injured_reserve(injured_reserve, %{"status" => "returned"})
    |> update_position_to_active(ir_position)
    |> update_position_to_dropped(replacement_position)
  end

  # Helpers

  defp update_injured_reserve(multi, injured_reserve, attrs) do
    Multi.update(multi, :injured_reserve, InjuredReserve.changeset(injured_reserve, attrs))
  end

  defp update_position_to_injured_reserve(multi, nil) do
    Multi.error(multi, :update_position_to_injured_reserve, "No roster position found for IR.")
  end

  defp update_position_to_injured_reserve(multi, position) do
    Multi.update(
      multi,
      :update_position_to_injured_reserve,
      RosterPosition.changeset(position, %{"status" => "injured_reserve"})
    )
  end

  defp create_replacement_position(multi, injured_reserve) do
    team_id = injured_reserve.fantasy_team_id
    player_id = injured_reserve.replacement_player_id

    params = %{
      "fantasy_team_id" => team_id,
      "fantasy_player_id" => player_id,
      "active_at" => DateTime.utc_now(),
      "position" => "Unassigned",
      "acq_method" => "injured_reserve",
      "status" => "active"
    }

    Multi.insert(
      multi,
      :create_replacement_position,
      RosterPosition.changeset(%RosterPosition{}, params)
    )
  end

  defp update_position_to_active(multi, nil), do: multi

  defp update_position_to_active(multi, position) do
    Multi.update(
      multi,
      :update_position_to_active,
      RosterPosition.changeset(position, %{"status" => "active"})
    )
  end

  defp update_position_to_dropped(multi, nil), do: multi

  defp update_position_to_dropped(multi, position) do
    Multi.update(
      multi,
      :update_position_to_dropped,
      RosterPosition.changeset(position, %{"status" => "dropped"})
    )
  end
end
