defmodule Ex338.AutoDraft do
  @moduledoc false

  alias Ex338.{DraftQueue, InSeasonDraftPick}
  alias Ex338Web.{InSeasonDraftEmail}

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
         %{fantasy_player_id: queued_player_id} <- get_top_queue(next_pick),
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

  defp get_top_queue(%InSeasonDraftPick{
         draft_pick_asset: %{fantasy_team_id: team_id},
         championship: %{sports_league_id: sport_id}
       }) do
    DraftQueue.Store.get_top_queue(team_id, sport_id)
  end

  defp send_email(pick) do
    league_id = pick.draft_pick_asset.fantasy_team.fantasy_league_id
    sport_id = pick.championship.sports_league_id
    InSeasonDraftEmail.send_update(league_id, sport_id)
  end
end
