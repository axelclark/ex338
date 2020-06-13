defmodule Ex338.FantasyTeams.StandingsHistory do
  @moduledoc """
  Functions to generate league standings history
  """

  @months ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]

  def get_dates_for_league(league) do
    %{year: year} = league
    Enum.map(@months, &format_date(&1, year))
  end

  def group_by_team(standings_by_month) do
    standings_by_month
    |> List.flatten()
    |> Enum.group_by(& &1.team_name)
    |> Enum.map(&format_team_data/1)
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
end
