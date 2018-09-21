defmodule Ex338Web.DraftPickView do
  use Ex338Web, :view

  alias Ex338.{DraftPick}

  def calculate_team_data(draft_picks) do
    draft_picks
    |> update_seconds_on_the_clock
    |> group_picks_by_team
    |> calculate_data_for_teams
    |> sort_by_avg_time_on_the_clock
  end

  def next_pick?(draft_picks, draft_pick) do
    Enum.find(draft_picks, &(&1.fantasy_player_id == nil)) == draft_pick
  end

  def seconds_to_hours(seconds) do
    Float.floor(seconds / 3600, 2)
  end

  def seconds_to_mins(seconds) do
    Float.floor(seconds / 60, 2)
  end

  ## Helpers

  ## calculate_team_data

  defp update_seconds_on_the_clock(draft_picks) do
    {teams, _last_pick} = Enum.map_reduce(draft_picks, :none, &calculate_seconds_on_the_clock/2)
    teams
  end

  defp calculate_seconds_on_the_clock(pick, :none) do
    {%{pick | seconds_on_the_clock: 0}, pick}
  end

  defp calculate_seconds_on_the_clock(pick, last_pick) do
    {%{
       pick
       | seconds_on_the_clock: NaiveDateTime.diff(pick.updated_at, last_pick.updated_at)
     }, pick}
  end

  defp group_picks_by_team(draft_picks) do
    Enum.group_by(draft_picks, & &1.fantasy_team_id)
  end

  defp calculate_data_for_teams(teams) do
    teams
    |> Enum.map(&sum_data_for_teams/1)
    |> Enum.map(&update_avg_time_on_the_clock/1)
  end

  defp sum_data_for_teams({_id, team_picks}) do
    Enum.reduce(team_picks, %{}, &calculate_team_data/2)
  end

  defp calculate_team_data(draft_pick, team_data) do
    team_data
    |> Map.put_new(:team_name, draft_pick.fantasy_team.team_name)
    |> update_seconds_and_picks(draft_pick)
  end

  defp update_seconds_and_picks(team_data, %DraftPick{fantasy_player_id: nil}) do
    team_data
    |> Map.put_new(:total_seconds_on_the_clock, 0)
    |> Map.put_new(:picks_selected, 0)
  end

  defp update_seconds_and_picks(team_data, draft_pick) do
    team_data
    |> Map.update(
      :total_seconds_on_the_clock,
      draft_pick.seconds_on_the_clock,
      &(&1 + draft_pick.seconds_on_the_clock)
    )
    |> Map.update(:picks_selected, 1, &(&1 + 1))
  end

  defp update_avg_time_on_the_clock(team_data) do
    %{picks_selected: picks, total_seconds_on_the_clock: secs} = team_data
    avg_time = calculate_avg_time_on_the_clock(secs, picks)
    Map.put(team_data, :avg_seconds_on_the_clock, avg_time)
  end

  defp calculate_avg_time_on_the_clock(0, _picks), do: 0

  defp calculate_avg_time_on_the_clock(secs, picks) do
    Float.floor(secs / picks, 2)
  end

  defp sort_by_avg_time_on_the_clock(teams) do
    Enum.sort(teams, &(&1.avg_seconds_on_the_clock <= &2.avg_seconds_on_the_clock))
  end
end
