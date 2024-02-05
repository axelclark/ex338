defmodule Ex338.AutoDraft do
  @moduledoc false

  alias Ex338.DraftPicks
  alias Ex338.DraftPicks.DraftPick
  alias Ex338.DraftQueues
  alias Ex338.FantasyTeams
  alias Ex338.InSeasonDraftPicks
  alias Ex338.InSeasonDraftPicks.InSeasonDraftPick
  alias Ex338Web.DraftEmail
  alias Ex338Web.InSeasonDraftEmail

  @next_pick 1

  def in_season_draft_pick_from_queues(fantasy_league_id, championship) do
    with {:in_progress, available_picks} <- draft_status?(fantasy_league_id, championship),
         {:ok, pick} <- make_in_season_pick(available_picks) do
      reorder_league_queues(pick)
      send_email(pick)
      {:ok, pick}
    else
      :draft_not_started -> {:ok, :draft_not_started}
      :in_season_draft_picks_complete -> {:ok, :in_season_draft_picks_complete}
      :queues_not_loaded -> {:ok, :queues_not_loaded}
    end
  end

  def make_picks_from_queues(:no_pick, previous_picks, _sleep_before_pick) do
    reorder_league_queues(List.first(previous_picks))
    Enum.reverse(previous_picks)
  end

  def make_picks_from_queues(last_pick, previous_picks, sleep_before_pick) do
    Process.sleep(sleep_before_pick)
    make_pick(last_pick, previous_picks, sleep_before_pick)
  end

  ## Helpers

  defp reorder_league_queues(nil), do: :none

  defp reorder_league_queues(%InSeasonDraftPick{
         draft_pick_asset: %{fantasy_team: %{fantasy_league_id: league_id}}
       }) do
    DraftQueues.reorder_for_league(league_id)
  end

  defp reorder_league_queues(%DraftPick{fantasy_league_id: league_id}) do
    DraftQueues.reorder_for_league(league_id)
  end

  defp get_top_queue(%InSeasonDraftPick{
         draft_pick_asset: %{fantasy_team_id: team_id},
         championship: %{sports_league_id: sport_id}
       }) do
    DraftQueues.get_top_queue_by_sport(team_id, sport_id)
  end

  defp get_top_queue(%DraftPick{fantasy_team: team}) do
    DraftQueues.get_top_queue(team.id)
  end

  defp check_autodraft_setting(%{autodraft_setting: :on}) do
    {:ok, :on}
  end

  defp check_autodraft_setting(%{autodraft_setting: :single} = fantasy_team) do
    FantasyTeams.update_team(fantasy_team, %{autodraft_setting: :off})
    {:ok, :single}
  end

  defp check_autodraft_setting(%{autodraft_setting: :off}) do
    {:error, :off}
  end

  defp send_email(%InSeasonDraftPick{} = pick) do
    InSeasonDraftEmail.send_update(pick)
  end

  defp send_email(%DraftPick{} = pick) do
    DraftEmail.send_update(pick)
  end

  defp send_error_email(changeset) do
    DraftEmail.send_error(changeset)
  end

  ## in_season_draft_pick_from_queues

  defp draft_status?(fantasy_league_id, championship) do
    with true <- draft_started?(championship),
         available_picks = InSeasonDraftPicks.available_picks(fantasy_league_id, championship),
         true <- any_available_picks?(available_picks) do
      {:in_progress, available_picks}
    end
  end

  defp draft_started?(championship) do
    %{draft_starts_at: draft_starts_at} = championship

    case DateTime.compare(draft_starts_at, DateTime.utc_now()) do
      :gt -> :draft_not_started
      _ -> true
    end
  end

  defp any_available_picks?(available_picks) do
    if Enum.any?(available_picks, &(&1.available_to_pick? == true)) do
      true
    else
      :in_season_draft_picks_complete
    end
  end

  defp make_in_season_pick(available_picks) do
    Enum.reduce_while(available_picks, :queues_not_loaded, fn next_pick, result ->
      with %{fantasy_player_id: queued_player_id, fantasy_team: fantasy_team} <-
             get_top_queue(next_pick),
           {:ok, _autodraft_setting} <- check_autodraft_setting(fantasy_team),
           {:ok, %{update_pick: pick}} <-
             InSeasonDraftPicks.draft_player(next_pick, %{
               "drafted_player_id" => queued_player_id
             }) do
        {:halt, {:ok, pick}}
      else
        _ -> {:cont, result}
      end
    end)
  end

  ## make_picks_from_queue

  defp make_pick(%DraftPick{fantasy_league_id: league_id}, picks, sleep_before_pick) do
    with [next_pick] <- DraftPicks.get_next_picks(league_id, @next_pick),
         %{fantasy_player_id: queued_player_id, fantasy_team: fantasy_team} <-
           get_top_queue(next_pick),
         {:ok, _autodraft_setting} <- check_autodraft_setting(fantasy_team),
         {:ok, %{draft_pick: pick}} <-
           DraftPicks.draft_player(next_pick, %{
             "fantasy_player_id" => queued_player_id
           }) do
      send_email(pick)
      make_picks_from_queues(pick, [pick | picks], sleep_before_pick)
    else
      {:error, :draft_pick, changeset, _} ->
        send_error_email(changeset)
        picks

      _ ->
        make_picks_with_skips(league_id, picks, sleep_before_pick)
    end
  end

  defp make_picks_with_skips(fantasy_league_id, previous_picks, sleep_before_pick) do
    available_picks = DraftPicks.get_picks_available_with_skips(fantasy_league_id)

    do_make_picks_with_skips(
      fantasy_league_id,
      available_picks,
      previous_picks,
      sleep_before_pick
    )
  end

  defp do_make_picks_with_skips(_, nil, picks, sleep_before_pick) do
    make_picks_from_queues(:no_pick, picks, sleep_before_pick)
  end

  defp do_make_picks_with_skips(fantasy_league_id, available_picks, picks, sleep_before_pick) do
    new_picks =
      Enum.reduce(available_picks, picks, fn next_pick, picks ->
        with %{fantasy_player_id: queued_player_id, fantasy_team: fantasy_team} <-
               get_top_queue(next_pick),
             {:ok, _autodraft_setting} <- check_autodraft_setting(fantasy_team),
             {:ok, %{draft_pick: pick}} <-
               DraftPicks.draft_player(next_pick, %{
                 "fantasy_player_id" => queued_player_id
               }) do
          send_email(pick)
          Process.sleep(sleep_before_pick)
          [pick | picks]
        else
          _ -> picks
        end
      end)

    if made_picks?(picks, new_picks) do
      make_picks_with_skips(fantasy_league_id, new_picks, sleep_before_pick)
    else
      make_picks_from_queues(:no_pick, picks, sleep_before_pick)
    end
  end

  defp made_picks?(picks, new_picks) do
    Enum.count(new_picks) > Enum.count(picks)
  end
end
