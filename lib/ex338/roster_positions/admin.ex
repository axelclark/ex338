defmodule Ex338.RosterPositions.Admin do
  @moduledoc false

  def primary_positions(roster_positions) do
    Enum.reject(roster_positions, fn roster_position ->
      flex_position?(roster_position.position) || unassigned_position?(roster_position.position)
    end)
  end

  def flex_and_unassigned_positions(roster_positions) do
    unassigned = unassigned_positions(roster_positions)
    flex = flex_positions(roster_positions)
    flex ++ unassigned
  end

  defp flex_positions(roster_positions) do
    Enum.filter(roster_positions, &flex_position?(&1.position))
  end

  defp flex_position?(position) do
    Regex.match?(~r/Flex/, position)
  end

  defp unassigned_positions(roster_positions) do
    Enum.filter(roster_positions, &unassigned_position?(&1.position))
  end

  def unassigned_position?(position) do
    Regex.match?(~r/Unassigned/, position)
  end

  def order_by_position(%{roster_positions: positions} = fantasy_teams) do
    positions
    |> sort_by_position
    |> sort_primary_positions_first
    |> update_fantasy_team(fantasy_teams)
  end

  defp sort_by_position(positions) do
    positions |> Enum.sort(&(&1.position <= &2.position))
  end

  defp sort_primary_positions_first(positions) do
    primary = primary_positions(positions)
    flex_and_unassigned = flex_and_unassigned_positions(positions)

    primary ++ flex_and_unassigned
  end

  def update_fantasy_team(positions, fantasy_team) do
    Map.put(fantasy_team, :roster_positions, positions)
  end
end
