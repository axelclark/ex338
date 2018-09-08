defmodule Ex338Web.FantasyTeamView do
  use Ex338Web, :view
  alias Ex338.{DraftQueue, FantasyLeague, FantasyTeam, RosterPosition}

  import Ex338.RosterPosition.RosterAdmin,
    only: [primary_positions: 1, flex_and_unassigned_positions: 1]

  def autodraft_setting_options() do
    FantasyTeam.autodraft_setting_options()
  end

  def display_autodraft_setting(:single), do: "Make Pick & Pause"

  def display_autodraft_setting(setting), do: String.capitalize(Atom.to_string(setting))

  def display_points(%{season_ended?: season_ended?} = roster_position) do
    roster_position.fantasy_player.championship_results
    |> List.first()
    |> display_value(season_ended?)
  end

  def display_points(_), do: ""

  def order_range(team_form_struct) do
    number_of_queues = Enum.count(team_form_struct.data.draft_queues)

    case number_of_queues do
      0 -> []
      total -> Enum.to_list(1..total)
    end
  end

  def position_selections(position_form_struct, %FantasyLeague{max_flex_spots: num_spots}) do
    [position_form_struct.data.fantasy_player.sports_league.abbrev] ++
      RosterPosition.flex_positions(num_spots)
  end

  def queue_status_options() do
    DraftQueue.owner_status_options()
  end

  def sort_by_position(query) do
    Enum.sort(query, &(&1.position <= &2.position))
  end

  ## Helpers

  ## display_points

  defp display_value(nil, false), do: ""
  defp display_value(nil, true), do: "-"
  defp display_value(result, _), do: Map.get(result, :points)
end
