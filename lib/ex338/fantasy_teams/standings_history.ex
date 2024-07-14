defmodule Ex338.FantasyTeams.StandingsHistory do
  @moduledoc """
  Functions to generate league standings history
  """

  alias Ex338.FantasyLeagues.FantasyLeague

  @months ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]

  def get_dates_for_league(league) do
    %{year: year} = league
    Enum.map(@months, &format_date(&1, year))
  end

  def list_dates_for_league(league) do
    %FantasyLeague{championships_start_at: start_at, championships_end_at: end_at} = league

    before_season =
      start_at
      |> DateTime.to_date()
      |> Date.beginning_of_month()
      |> DateTime.new!(~T[00:00:00.000], "Etc/UTC")

    calculate_dates(before_season, end_at)
  end

  defp calculate_dates(datetime, championships_end_at, dates \\ []) do
    if DateTime.before?(datetime, championships_end_at) do
      dates = [datetime | dates]
      new_datetime = DateTime.shift(datetime, month: 1)
      calculate_dates(new_datetime, championships_end_at, dates)
    else
      dates = [championships_end_at | dates]
      Enum.reverse(dates)
    end
  end

  def group_by_team(standings_by_month) do
    standings_by_month
    |> List.flatten()
    |> Enum.group_by(& &1.team_name)
    |> Enum.map(&format_team_data/1)
  end

  def format_for_chart(standings_by_month, datetimes_for_league) do
    last_date = List.last(datetimes_for_league)

    datetimes_for_league
    |> Enum.zip_with(standings_by_month, fn datetime, standings ->
      datetime =
        if datetime == last_date do
          shift_to_beginning_of_next_month(datetime)
        else
          datetime
        end

      Enum.map(standings, fn team ->
        %{date: datetime, team_name: team.team_name, points: team.points}
      end)
    end)
    |> List.flatten()
  end

  ## Helpers

  ## get_dates_for_league

  defp format_date(month, year) do
    iso_datetime = "#{year}-#{month}-01T00:00:00Z"
    {:ok, datetime, _} = DateTime.from_iso8601(iso_datetime)
    datetime
  end

  ## group_by_team

  defp format_team_data({_team, data}) do
    Enum.reduce(data, %{}, fn data, acc ->
      acc
      |> Map.put_new(:team_name, data.team_name)
      |> Map.update(:points, [data.points], &(&1 ++ [data.points]))
    end)
  end

  ## group_by_team

  defp shift_to_beginning_of_next_month(datetime) do
    datetime
    |> DateTime.to_date()
    |> Date.end_of_month()
    |> DateTime.new!(~T[00:00:00.000], "Etc/UTC")
    |> DateTime.shift(day: 1)
  end
end
