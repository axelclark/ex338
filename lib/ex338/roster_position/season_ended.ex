defmodule Ex338.RosterPosition.SeasonEnded do
  @moduledoc """
  Adds season_ended? boolean to roster positions
  """

  def add_for_league(teams) do
    Enum.map(teams, &(add_for_team(&1)))
  end

  def add_for_team(%{roster_positions: positions} = team) do
    positions = calculate_season_ended(positions)

    team
    |> Map.delete(:roster_positions)
    |> Map.put(:roster_positions, positions)
  end

  ## Implementations

  ## add_for_team

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
