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

  def update_teams_in_picks(draft_picks, fantasy_teams) do
    Enum.map(draft_picks, &get_and_update_team(&1, fantasy_teams))
  end

  ## Helpers

  ## calculate_team_data

  defp group_picks_by_team(draft_picks) do
    Enum.group_by(draft_picks, & &1.fantasy_team)
  end

  defp calculate_data_for_teams(teams) do
    teams
    |> Stream.map(&sum_data_for_teams/1)
    |> Stream.map(&update_avg_time_on_the_clock/1)
    |> Enum.map(&update_draft_status/1)
  end

  defp sum_data_for_teams({team, team_picks}) do
    total_draft_secs_adj = team.total_draft_mins_adj * 60
    team = %{team | total_seconds_on_the_clock: total_draft_secs_adj}

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
    Enum.sort(teams, &(&1.total_seconds_on_the_clock <= &2.total_seconds_on_the_clock))
  end

  defp update_draft_status(fantasy_team) do
    max_draft_hours = fantasy_team.fantasy_league.max_draft_hours
    max_draft_seconds = max_draft_hours * 60 * 60

    over_draft_time_limit? = over_limit?(fantasy_team, max_draft_seconds)

    %{fantasy_team | over_draft_time_limit?: over_draft_time_limit?}
  end

  defp over_limit?(_fantasy_team, 0), do: false

  defp over_limit?(fantasy_team, max_draft_seconds) do
    fantasy_team.total_seconds_on_the_clock > max_draft_seconds
  end

  ## update_seconds_on_the_clock

  defp calculate_seconds_on_the_clock(pick, :none) do
    {%{pick | seconds_on_the_clock: 0}, pick}
  end

  defp calculate_seconds_on_the_clock(%{fantasy_player_id: nil} = pick, _last_pick) do
    {%{pick | seconds_on_the_clock: nil}, pick}
  end

  defp calculate_seconds_on_the_clock(pick, %{drafted_at: nil} = last_pick) do
    {%{
       pick
       | seconds_on_the_clock: 0
     }, last_pick}
  end

  defp calculate_seconds_on_the_clock(pick, last_pick) do
    case DateTime.diff(pick.drafted_at, last_pick.drafted_at) do
      seconds when seconds < 0 ->
        {%{
           pick
           | seconds_on_the_clock: 0
         }, last_pick}

      seconds ->
        {%{
           pick
           | seconds_on_the_clock: seconds
         }, pick}
    end
  end

  ## get_and_update_team

  defp get_and_update_team(draft_pick, fantasy_teams) do
    {_old_team, updated_pick} =
      Map.get_and_update!(draft_pick, :fantasy_team, fn current_team ->
        new_team =
          Enum.find(fantasy_teams, fn new_team ->
            new_team.id == current_team.id
          end)

        {current_team, new_team}
      end)

    updated_pick
  end
end
