defmodule Ex338.FantasyLeagueView do
  use Ex338.Web, :view

  import Ex338.FantasyTeamView, only: [calculate_points: 1]

  def sort_by_points(fantasy_teams) do
    Enum.sort(fantasy_teams, &(calculate_points(&1) >= calculate_points(&2)))
  end
end
