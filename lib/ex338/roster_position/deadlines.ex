defmodule Ex338.RosterPosition.Deadlines do
  @moduledoc """
  Adds season_ended? boolean to roster positions
  """

  @deadlines [:season_ended?, :trades_closed?, :waivers_closed?]

  def add_for_league(teams) do
    Enum.map(teams, &add_for_team(&1))
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
    Enum.map(positions, &verify_and_add_info(&1))
  end

  defp verify_and_add_info(
         %{fantasy_player: %{sports_league: %{championships: [overall]}}} = position
       ) do
    %{
      championship_at: championship_at,
      waiver_deadline_at: waiver_deadline_at,
      trade_deadline_at: trade_deadline_at
    } = overall

    season_ended? = compare_to_today(championship_at)
    waivers_closed? = compare_to_today(waiver_deadline_at)
    trades_closed? = compare_to_today(trade_deadline_at)

    position
    |> Map.put(:season_ended?, season_ended?)
    |> Map.put(:waivers_closed?, waivers_closed?)
    |> Map.put(:trades_closed?, trades_closed?)
  end

  defp verify_and_add_info(position) do
    Enum.reduce(@deadlines, position, fn deadline, position ->
      Map.put(position, deadline, false)
    end)
  end

  defp compare_to_today(championship_date) do
    now = DateTime.utc_now()
    result = DateTime.compare(championship_date, now)

    did_deadline_pass?(result)
  end

  defp did_deadline_pass?(:gt), do: false
  defp did_deadline_pass?(:eq), do: false
  defp did_deadline_pass?(:lt), do: true
end
