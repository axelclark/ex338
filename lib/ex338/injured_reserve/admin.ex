defmodule Ex338.InjuredReserve.Admin do
  @moduledoc """
  Returns an `Ecto.Multi` with actions to process an approved `InjuredReserve`.
  """

  alias Ecto.Multi
  alias Ex338.{InjuredReserve, RosterPosition}

  def process_ir(ir, attrs, positions) do
    Multi.new()
    |> update_ir(ir, attrs)
    |> update_ir_position(ir, positions)
    |> update_replacement_position(ir, positions)
  end

  defp update_ir(multi, {_, ir}, attrs) do
    Multi.update(multi, :ir, InjuredReserve.changeset(ir, attrs))
  end

  defp update_ir_position(multi, {:add, _ir}, %{ir: position}) do
    Multi.update(
      multi,
      :active_to_ir,
      RosterPosition.changeset(position, %{"status" => "injured_reserve"})
    )
  end

  defp update_ir_position(multi, {:remove, _ir}, %{ir: position}) do
    [unassigned] = RosterPosition.default_position()

    Multi.update(
      multi,
      :ir_to_active,
      RosterPosition.changeset(position, %{"status" => "active", "position" => unassigned})
    )
  end

  defp update_replacement_position(multi, {:add, ir}, _positions) do
    team_id = ir.fantasy_team_id
    player_id = ir.replacement_player_id

    params = %{
      "fantasy_team_id" => team_id,
      "fantasy_player_id" => player_id,
      "active_at" => DateTime.utc_now(),
      "position" => "Unassigned",
      "status" => "active"
    }

    Multi.insert(
      multi,
      :add_replacement,
      RosterPosition.changeset(%RosterPosition{}, params)
    )
  end

  defp update_replacement_position(multi, {:remove, _ir}, %{replacement: position}) do
    Multi.update(
      multi,
      :drop_replacement,
      RosterPosition.changeset(position, %{"status" => "dropped"})
    )
  end
end
