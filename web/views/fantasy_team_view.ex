defmodule Ex338.FantasyTeamView do
  use Ex338.Web, :view
  alias Ex338.{RosterPosition}
  import Ex338.RosterPosition.RosterAdmin, only: [primary_positions: 1,
                                                  flex_and_unassigned_positions: 1]

  def sort_by_position(query) do
    Enum.sort(query, &(&1.position <= &2.position))
  end

  def position_selections(r) do
    [r.data.fantasy_player.sports_league.abbrev] ++ RosterPosition.flex_positions
  end

  def display_points(%{season_ended?: season_ended?} = roster_position) do

    roster_position.fantasy_player.championship_results
    |> List.first
    |> display_value(season_ended?)
  end

  def display_points(_), do: ""

  defp display_value(nil, false), do: ""
  defp display_value(nil, true),  do: "-"
  defp display_value(result, _),  do: Map.get(result, :points)
end
