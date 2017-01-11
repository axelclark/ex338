defmodule Ex338.FantasyLeagueView do
  use Ex338.Web, :view

  import Ex338.FantasyTeamView, only: [calculate_points: 1]

  def sort_and_rank(fantasy_teams) do
    fantasy_teams
    |> sort_by_points
    |> add_rank
  end

  def sort_by_points(fantasy_teams) do
    Enum.sort(fantasy_teams, &(calculate_points(&1) >= calculate_points(&2)))
  end

  defp add_rank(fantasy_teams) do
    {teams, _} = Enum.map_reduce fantasy_teams, 1, fn(team, acc) ->
     {Map.put(team, :rank, acc), acc + 1}
    end

    teams
  end
end
