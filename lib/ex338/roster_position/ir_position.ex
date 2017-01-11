defmodule Ex338.RosterPosition.IRPosition do
  @moduledoc false

  def separate_from_active_for_teams(fantasy_teams) do
    Enum.map(fantasy_teams, &(separate_from_active_for_team(&1)))
  end

  def separate_from_active_for_team(
    %{roster_positions: roster_positions} = fantasy_team) do

    {ir_positions, active_positions} =
      split_ir_and_active_positions(roster_positions)

    ir_positions = set_position_to_ir(ir_positions)

    fantasy_team
    |> Map.delete(:roster_positions)
    |> Map.put(:ir_positions, ir_positions)
    |> Map.put(:roster_positions, active_positions)
  end

  def separate_from_active_for_team(fantasy_team) do
    fantasy_team
  end

  defp split_ir_and_active_positions(roster_positions) do
    Enum.partition(roster_positions, &(&1.status == "injured_reserve"))
  end

  defp set_position_to_ir(ir_positions) do
    Enum.map(ir_positions, &(Map.put(&1, :position, "Injured Reserve")))
  end
end
