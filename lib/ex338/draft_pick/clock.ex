defmodule Ex338.DraftPick.Clock do
  alias Ex338.{DraftPick}

  def calculate_team_data(draft_picks) do
    draft_picks
    |> group_picks_by_team
    |> calculate_data_for_teams
    |> sort_by_avg_time_on_the_clock
  end

  def update_seconds_on_the_clock(draft_picks) do
    {picks, _last_pick} = Enum.map_reduce(draft_picks, :none, &calculate_seconds_on_the_clock/2)
    picks
  end

  ## Helpers

  ## calculate_team_data

  defp group_picks_by_team(draft_picks) do
    Enum.group_by(draft_picks, & &1.fantasy_team)
  end

  defp calculate_data_for_teams(teams) do
    teams
    |> Stream.map(&sum_data_for_teams/1)
    |> Enum.map(&update_avg_time_on_the_clock/1)
  end

  defp sum_data_for_teams({team, team_picks}) do
    Enum.reduce(team_picks, team, &update_seconds_and_picks/2)
  end

  defp update_seconds_and_picks(%DraftPick{fantasy_player_id: nil}, team_data) do
    team_data
  end

  defp update_seconds_and_picks(draft_pick, team_data) do
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

  ## update_seconds_on_the_clock

  defp calculate_seconds_on_the_clock(pick, :none) do
    {%{pick | seconds_on_the_clock: 0}, pick}
  end

  defp calculate_seconds_on_the_clock(%{fantasy_player_id: nil} = pick, _last_pick) do
    {%{pick | seconds_on_the_clock: nil}, pick}
  end

  defp calculate_seconds_on_the_clock(pick, last_pick) do
    {%{
       pick
       | seconds_on_the_clock: DateTime.diff(pick.drafted_at, last_pick.drafted_at)
     }, pick}
  end
end
