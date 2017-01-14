defmodule Ex338.FantasyTeam.Winnings do
  @moduledoc false

  def get_winnings_for_teams(teams) do
    Enum.map(teams, &(get_winnings(&1)))
  end

  def get_winnings(%{roster_positions: positions} = fantasy_team) do
    winnings = calculate_winnings(positions)
    save_winnings(fantasy_team, winnings)
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

  defp save_winnings(fantasy_team, winnings) do
    Map.put(fantasy_team, :winnings, winnings)
  end
end
