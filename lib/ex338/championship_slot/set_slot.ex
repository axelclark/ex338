defmodule Ex338.ChampionshipSlot.SetSlot do
  @moduledoc false

  alias Ex338.{RosterAdmin}

  def update_team_slots(team) do
    team
    |> RosterAdmin.order_by_position
    |> add_slot_to_position
  end

  defp add_slot_to_position(team) do
    {positions_with_slots, _} =
      Enum.map_reduce team.roster_positions, 1, fn(pos, acc) ->
        {Map.put(pos, :slot, acc), acc + 1}
      end
    update_roster_positions(team, positions_with_slots)
  end

  defp update_roster_positions(team, new_positions) do
    team
    |> Map.delete(:roster_positions)
    |> Map.put(:roster_positions, new_positions)
  end
end
