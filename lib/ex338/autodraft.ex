defmodule Ex338.AutoDraft do
  @moduledoc false

  alias Ex338.{DraftPick, DraftQueue, FantasyTeam, InSeasonDraftPick}
  alias Ex338Web.{DraftEmail, InSeasonDraftEmail}

  @next_pick 1

  def make_picks_from_queues(last_pick, new_picks \\ [])

  def make_picks_from_queues(:no_pick, new_picks) do
    Enum.reverse(new_picks)
  end

  def make_picks_from_queues(last_pick, new_picks) do
    make_pick(last_pick, new_picks)
  end

  ## Helpers

  ## from_queue

  defp make_pick(
         %InSeasonDraftPick{
           draft_pick_asset: %{fantasy_team: %{fantasy_league_id: league_id}},
           championship: %{sports_league_id: sport_id}
         },
         picks
       ) do
    with [next_pick] <- InSeasonDraftPick.Store.next_picks(league_id, sport_id, @next_pick),
         %{fantasy_player_id: queued_player_id, fantasy_team: fantasy_team} <-
           get_top_queue(next_pick),
         {:ok, _autodraft_setting} <- check_autodraft_setting(fantasy_team),
         {:ok, %{update_pick: pick}} <-
           InSeasonDraftPick.Store.draft_player(next_pick, %{
             "drafted_player_id" => queued_player_id
           }) do
      send_email(pick)
      make_picks_from_queues(pick, [pick] ++ picks)
    else
      _ -> make_picks_from_queues(:no_pick, picks)
    end
  end

  defp make_pick(%DraftPick{fantasy_league_id: league_id}, picks) do
    with [next_pick] <- DraftPick.Store.get_next_picks(league_id, @next_pick),
         %{fantasy_player_id: queued_player_id, fantasy_team: fantasy_team} <-
           get_top_queue(next_pick),
         {:ok, _autodraft_setting} <- check_autodraft_setting(fantasy_team),
         {:ok, %{draft_pick: pick}} <-
           DraftPick.Store.draft_player(next_pick, %{
             "fantasy_player_id" => queued_player_id
           }) do
      send_email(pick)
      make_picks_from_queues(pick, [pick] ++ picks)
    else
      _ -> make_picks_from_queues(:no_pick, picks)
    end
  end

  defp get_top_queue(%InSeasonDraftPick{
         draft_pick_asset: %{fantasy_team_id: team_id},
         championship: %{sports_league_id: sport_id}
       }) do
    DraftQueue.Store.get_top_queue_by_sport(team_id, sport_id)
  end

  defp get_top_queue(%DraftPick{fantasy_team: team}) do
    DraftQueue.Store.get_top_queue(team.id)
  end

  defp check_autodraft_setting(%{autodraft_setting: :on}) do
    {:ok, :on}
  end

  defp check_autodraft_setting(%{autodraft_setting: :single} = fantasy_team) do
    FantasyTeam.Store.update_team(fantasy_team, %{autodraft_setting: :off})
    {:ok, :single}
  end

  defp check_autodraft_setting(%{autodraft_setting: :off}) do
    {:error, :off}
  end

  defp send_email(%InSeasonDraftPick{} = pick) do
    league_id = pick.draft_pick_asset.fantasy_team.fantasy_league_id
    sport_id = pick.championship.sports_league_id
    InSeasonDraftEmail.send_update(league_id, sport_id)
  end

  defp send_email(%DraftPick{} = pick) do
    DraftEmail.send_update(pick)
  end
end
