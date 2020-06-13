defmodule Ex338.FantasyTeams.Standings do
  @moduledoc """
  Functions to generate league standings
  """

  def rank_points_winnings_for_teams(teams) do
    teams
    |> Enum.map(&update_points_winnings(&1))
    |> sort_by_points
    |> add_rank
  end

  def update_points_winnings(fantasy_team) do
    points = calculate_all_points(fantasy_team)
    winnings = calculate_all_winnings(fantasy_team)

    fantasy_team
    |> Map.put(:points, points)
    |> Map.put(:winnings, winnings)
  end

  ## Implementations

  ## rank_points_winnings_for_teams

  defp sort_by_points(fantasy_teams) do
    Enum.sort(fantasy_teams, &(&1.points >= &2.points))
  end

  defp add_rank(fantasy_teams) do
    {teams, _} =
      Enum.map_reduce(fantasy_teams, 1, fn team, acc ->
        {Map.put(team, :rank, acc), acc + 1}
      end)

    teams
  end

  ## update_points_winnings

  defp calculate_all_points(%{roster_positions: positions, champ_with_events_results: results}) do
    player_points = calculate_position_points(positions)
    champ_with_events_points = calculate_points_from_results(results)

    player_points + champ_with_events_points
  end

  defp calculate_position_points(positions) do
    Enum.reduce(positions, 0, fn position, acc ->
      results = position.fantasy_player.championship_results
      calculate_points_from_results(results) + acc
    end)
  end

  defp calculate_points_from_results(results) do
    Enum.reduce(results, 0, fn result, acc ->
      result.points + acc
    end)
  end

  defp calculate_all_winnings(%{
         winnings_adj: winnings_adj,
         roster_positions: positions,
         champ_with_events_results: results
       }) do
    player_winnings = calculate_position_winnings(positions)
    champ_with_events_winnings = calculate_winnings_from_results(results)

    player_winnings + champ_with_events_winnings + winnings_adj
  end

  defp calculate_position_winnings(positions) do
    Enum.reduce(positions, 0, fn position, acc ->
      results = position.fantasy_player.championship_results
      calculate_winnings_from_results(results) + acc
    end)
  end

  defp calculate_winnings_from_results(results) do
    Enum.reduce(results, 0, fn result, acc ->
      calc_winnings(result) + acc
    end)
  end

  defp calc_winnings(%{winnings: winnings}), do: winnings
  defp calc_winnings(%{rank: 1}), do: 25
  defp calc_winnings(%{rank: 2}), do: 10
  defp calc_winnings(_), do: 0
end
