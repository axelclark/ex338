defmodule Ex338.ValidateHelpers do
  @moduledoc false

  def slot_available?(roster_positions, max_flex_spots) do
    total_slot_count = count_total_slots(roster_positions)

    roster_positions
    |> count_regular_slots
    |> calculate_flex_slots_used(total_slot_count)
    |> compare_flex_slots(max_flex_spots)
  end

  ## Helpers

  ## slot_available?

  defp count_total_slots(slots) do
    Enum.count(slots)
  end

  defp count_regular_slots(slots) do
    slots
    |> Enum.map(& &1.fantasy_player.sports_league_id)
    |> Enum.uniq()
    |> Enum.count()
  end

  defp calculate_flex_slots_used(regular_slots_filled, total_filled) do
    total_filled - regular_slots_filled
  end

  defp compare_flex_slots(num_filled, max_flex_spots) do
    num_filled <= max_flex_spots
  end
end
