defmodule Ex338.FantasyTeam.Standings do
  @moduledoc false

  def rank_points_winnings_for_teams(teams) do
    teams
    |> Enum.map(&(update_points_winnings(&1)))
    |> sort_by_points
    |> add_rank
  end

  def update_points_winnings(fantasy_team) do
    points   = calculate_all_points(fantasy_team)
    winnings = calculate_all_winnings(fantasy_team)

    fantasy_team
    |> Map.put(:points, points)
    |> Map.put(:winnings, winnings)
  end

  def calculate_all_points(%{roster_positions: positions,
    champ_with_events_results: results}) do
      player_points = calculate_position_points(positions)
      champ_with_events_points = calculate_points_from_results(results)

      player_points + champ_with_events_points
  end

  defp calculate_position_points(positions) do
    Enum.reduce positions, 0, fn(position, acc) ->
      results = position.fantasy_player.championship_results
      calculate_points_from_results(results) + acc
    end
  end

  defp calculate_points_from_results(results) do
    Enum.reduce results, 0, fn(result, acc) ->
      result.points + acc
    end
  end

  def calculate_all_winnings(%{roster_positions: positions,
    champ_with_events_results: results}) do
      player_winnings = calculate_position_winnings(positions)
      champ_with_events_winnings = calculate_winnings_from_results(results)

      player_winnings + champ_with_events_winnings
  end

  defp calculate_position_winnings(positions) do
    Enum.reduce positions, 0, fn(position, acc) ->
      results = position.fantasy_player.championship_results
      calculate_winnings_from_results(results) + acc
    end
  end

  defp calculate_winnings_from_results(results) do
    Enum.reduce results, 0, fn(result, acc) ->
      calc_winnings(result) + acc
    end
  end

  defp calc_winnings(%{winnings: winnings}), do: winnings
  defp calc_winnings(%{rank: 1}), do: 25
  defp calc_winnings(%{rank: 2}), do: 10
  defp calc_winnings(_), do: 0

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
    Enum.map(positions, &(verify_and_add_info(&1)))
  end

  defp verify_and_add_info(
    %{fantasy_player: %{sports_league: %{championships: []}}} = position) do
      Map.put(position, :season_ended?, false)
  end

  defp verify_and_add_info(
    %{fantasy_player: %{sports_league: %{championships: overall}}} = position) do

      season_ended? =
        overall
        |> get_championship_date
        |> compare_to_today

      Map.put(position, :season_ended?, season_ended?)
  end

  defp verify_and_add_info(position) do
    Map.put(position, :season_ended?, false)
  end

  defp get_championship_date(overall) do
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
