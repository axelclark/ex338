defmodule Ex338.InSeasonDraftPicks.Clock do
  def update_in_season_draft_picks(in_season_draft_picks, %{draft_starts_at: nil}) do
    in_season_draft_picks
  end

  def update_in_season_draft_picks(in_season_draft_picks, championship) do
    {draft_picks, _last_pick} =
      Enum.map_reduce(in_season_draft_picks, nil, fn pick, last_pick ->
        pick =
          pick
          |> update_available_to_pick?(last_pick, championship)
          |> update_pick_due_at(last_pick, championship)
          |> update_over_time?()

        {pick, pick}
      end)

    draft_picks
  end

  defp update_available_to_pick?(pick, nil, championship) do
    available_to_pick? = draft_started?(championship) && pick.drafted_player_id == nil
    %{pick | available_to_pick?: available_to_pick?}
  end

  defp update_available_to_pick?(pick, last_pick, _) do
    available_to_pick? =
      (pick.drafted_player_id == nil &&
         last_pick.drafted_player_id != nil) || last_pick.over_time?

    %{pick | available_to_pick?: available_to_pick?}
  end

  defp draft_started?(championship) do
    %{draft_starts_at: draft_starts_at} = championship

    case DateTime.compare(draft_starts_at, DateTime.utc_now()) do
      :gt -> false
      _ -> true
    end
  end

  defp update_pick_due_at(pick, nil, championship) do
    %{max_draft_mins: max_draft_mins, draft_starts_at: draft_starts_at} = championship
    pick_due_at = DateTime.add(draft_starts_at, max_draft_mins * 60, :second)

    %{pick | pick_due_at: pick_due_at}
  end

  defp update_pick_due_at(pick, last_pick, championship) do
    %{max_draft_mins: max_draft_mins} = championship

    pick_due_at =
      if last_pick.drafted_player_id do
        DateTime.add(last_pick.drafted_at, max_draft_mins * 60, :second)
      else
        DateTime.add(last_pick.pick_due_at, max_draft_mins * 60, :second)
      end

    %{pick | pick_due_at: pick_due_at}
  end

  defp update_over_time?(%{drafted_player_id: nil} = pick) do
    over_time? =
      case DateTime.compare(pick.pick_due_at, DateTime.utc_now()) do
        :lt -> true
        _ -> false
      end

    %{pick | over_time?: over_time?}
  end

  defp update_over_time?(pick) do
    over_time? =
      case DateTime.compare(pick.pick_due_at, pick.drafted_at) do
        :lt -> true
        _ -> false
      end

    %{pick | over_time?: over_time?}
  end
end
