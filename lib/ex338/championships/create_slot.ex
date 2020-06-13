defmodule Ex338.Championships.CreateSlot do
  @moduledoc false

  alias Ecto.Multi
  alias Ex338.{RosterPositions.Admin, Championships.ChampionshipSlot, Repo}

  def create_slots_from_positions(teams, championship_id) do
    teams
    |> Enum.map(&calculate_slots_for_team(&1))
    |> retrieve_positions_to_array
    |> insert_slots(championship_id)
    |> Repo.transaction()
  end

  def calculate_slots_for_team(team) do
    team
    |> Admin.order_by_position()
    |> add_slot_to_position
  end

  defp add_slot_to_position(team) do
    {positions_with_slots, _} =
      Enum.map_reduce(team.roster_positions, 1, fn pos, acc ->
        {Map.put(pos, :slot, acc), acc + 1}
      end)

    update_roster_positions(team, positions_with_slots)
  end

  defp update_roster_positions(team, new_positions) do
    Map.put(team, :roster_positions, new_positions)
  end

  defp retrieve_positions_to_array(teams) do
    Enum.flat_map(teams, & &1.roster_positions)
  end

  defp insert_slots(positions, championship_id) do
    Enum.reduce(positions, Multi.new(), fn position, multi ->
      insert_slot_from_position(multi, position, championship_id)
    end)
  end

  defp insert_slot_from_position(multi, position, championship_id) do
    attrs = %{
      roster_position_id: position.id,
      championship_id: championship_id,
      slot: position.slot
    }

    multi_name = create_multi_name(position.id)
    changeset = ChampionshipSlot.changeset(%ChampionshipSlot{}, attrs)
    Multi.insert(multi, multi_name, changeset)
  end

  defp create_multi_name(id) do
    String.to_atom("insert_slot_for_position#{id}")
  end
end
