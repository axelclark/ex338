defmodule Ex338.DraftQueue.Admin do
  @moduledoc false

  alias Ex338.{DraftPick, DraftQueue, InSeasonDraftPick}

  def update_unavailable_from_pick(
    %DraftPick{
      fantasy_player_id: player_id,
      fantasy_team: %{fantasy_league_id: league_id}
    }
  ), do: do_update_unavailable(player_id, league_id)

  def update_unavailable_from_pick(
    %InSeasonDraftPick{
      drafted_player_id: player_id,
      draft_pick_asset: %{
        fantasy_team: %{fantasy_league_id: league_id}
      }
    }
  ), do: do_update_unavailable(player_id, league_id)

  ## Helpers

  ## update_unavailable_from_pick

  def do_update_unavailable(fantasy_player_id, fantasy_league_id) do
    DraftQueue
    |> DraftQueue.by_player(fantasy_player_id)
    |> DraftQueue.by_league(fantasy_league_id)
    |> DraftQueue.only_pending
    |> DraftQueue.update_to_unavailable
  end
end
