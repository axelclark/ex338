defmodule Ex338.FantasyTeam.Standings do
  @moduledoc false

  def update_points_winnings_for_teams(teams) do
    teams
    |> Enum.map(&(update_points_winnings(&1)))
    |> sort_by_points
    |> add_rank
  end

  def update_points_winnings(%{roster_positions: positions} = fantasy_team) do
    points   = calculate_points(positions)
    winnings = calculate_winnings(positions)

    fantasy_team
    |> Map.put(:points, points)
    |> Map.put(:winnings, winnings)
  end

  defp calculate_points(positions) do
    Enum.reduce positions, 0, fn(position, acc) ->
      calculate_player_points(position.fantasy_player) + acc
    end
  end

  defp calculate_player_points(%{championship_results: results}) do
    Enum.reduce results, 0, fn(result, acc) ->
      result.points + acc
    end
  end

  defp calculate_winnings(positions) do
    Enum.reduce positions, 0, fn(position, acc) ->
      calculate_player_winnings(position.fantasy_player) + acc
    end
  end

  defp calculate_player_winnings(%{championship_results: results}) do
    Enum.reduce results, 0, fn(result, acc) ->
      rank_to_winnings(result.rank) + acc
    end
  end

  defp rank_to_winnings(1), do: 25
  defp rank_to_winnings(2), do: 10
  defp rank_to_winnings(_), do: 0

  defp sort_by_points(fantasy_teams) do
    Enum.sort(fantasy_teams, &(&1.points >= &2.points))
  end

  defp add_rank(fantasy_teams) do
    {teams, _} = Enum.map_reduce fantasy_teams, 1, fn(team, acc) ->
     {Map.put(team, :rank, acc), acc + 1}
    end

    teams
  end
end
