defmodule Ex338.Waiver.Batch do
  @moduledoc false

  def group_and_sort(waivers) do
    waivers
    |> group_by_league()
    |> Enum.map(&group_by_add_player/1)
    |> flatten_league_waivers()
    |> sort_by_process_at()
    |> Enum.map(&sort_by_waiver_position/1)
  end

  def group_by_league(waivers) do
    waivers
    |> Enum.group_by(& &1.fantasy_team.fantasy_league_id)
    |> convert_group_to_list()
  end

  def group_by_add_player(waivers) do
    waivers
    |> Enum.group_by(& &1.add_fantasy_player_id)
    |> convert_group_to_list()
  end

  def sort_by_waiver_position(waivers) do
    Enum.sort(waivers, &compare_waiver_positions/2)
  end

  def sort_by_process_at(waivers) do
    Enum.sort(waivers, &compare_process_at/2)
  end

  ## Helpers

  ## Implementations

  def convert_group_to_list(map) do
    Enum.map(map, fn {_key, value} -> value end)
  end

  ## batch

  defp flatten_league_waivers(waivers) do
    Enum.reduce(waivers, [], fn waivers, acc -> acc ++ waivers end)
  end

  ## sort_by_waiver_position
  defp compare_waiver_positions(_waiver, []), do: true

  defp compare_waiver_positions(waiver1, waiver2) do
    waiver1.fantasy_team.waiver_position <= waiver2.fantasy_team.waiver_position
  end

  ## sort_by_process_at

  defp compare_process_at([waiver1 | _], [waiver2 | _]) do
    case DateTime.compare(waiver1.process_at, waiver2.process_at) do
      :gt -> false
      :eq -> false
      :lt -> true
    end
  end
end
