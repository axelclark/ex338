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

  def add_season_ended_for_league(teams) do
    Enum.map(teams, &(add_season_ended(&1)))
  end

  def add_season_ended(%{roster_positions: positions} = team) do
    positions = calculate_season_ended(positions)

    team
    |> Map.delete(:roster_positions)
    |> Map.put(:roster_positions, positions)
  end

  defp calculate_season_ended(positions) do
    Enum.map positions, fn(position) ->
      season_ended? =
        position
        |> get_championship_date
        |> compare_to_today

      Map.put(position, :season_ended?, season_ended?)
    end
  end

  defp get_championship_date(
    %{fantasy_player: %{sports_league: %{championships: overall}}}) do

     overall
     |> List.first
     |> Map.get(:championship_at)
  end

  defp compare_to_today(championship_date) do
    now    = Ecto.DateTime.utc()
    result = Ecto.DateTime.compare(championship_date, now)

    did_season_end?(result)
  end

  defp did_season_end?(:gt), do: false
  defp did_season_end?(:eq), do: false
  defp did_season_end?(:lt), do: true
end
