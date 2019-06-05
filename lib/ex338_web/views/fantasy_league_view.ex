defmodule Ex338Web.FantasyLeagueView do
  use Ex338Web, :view

  @line_colors [
    "#e6194B",
    "#3cb44b",
    "#ffe119",
    "#4363d8",
    "#f58231",
    "#42d4f4",
    "#f032e6",
    "#fabebe",
    "#469990",
    "#e6beff",
    "#9A6324",
    "#800000",
    "#000075",
    "#aaffc3",
    "#fffac8"
  ]

  def format_and_encode_dataset(standings_history) do
    standings_history
    |> format_dataset()
    |> Jason.encode!()
  end

  def format_dataset(standings_history) do
    standings_history
    |> Enum.map(&update_keys(&1))
    |> Enum.zip(@line_colors)
    |> Enum.map(&add_colors(&1))
  end

  ## Helpers

  ## format_dataset

  defp update_keys(team_data) do
    team_data
    |> Map.put_new(:data, team_data.points)
    |> Map.put_new(:label, team_data.team_name)
    |> Map.put_new(:fill, false)
    |> Map.delete(:points)
    |> Map.delete(:team_name)
  end

  defp add_colors({team_data, color}) do
    team_data
    |> Map.put_new(:borderColor, color)
    |> Map.put_new(:backgroundColor, color)
  end
end
