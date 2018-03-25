defmodule Ex338.DraftQueue.Admin do
  @moduledoc false

  alias Ex338.{DraftPick, DraftQueue, InSeasonDraftPick}

  def update_drafted_from_pick(%DraftPick{
        fantasy_player_id: player_id,
        fantasy_team_id: team_id,
        fantasy_team: %{fantasy_league_id: league_id}
      }),
      do: do_update_drafted(player_id, team_id, league_id)

  def update_drafted_from_pick(%InSeasonDraftPick{
        drafted_player_id: player_id,
        draft_pick_asset: %{
          fantasy_team_id: team_id,
          fantasy_team: %{fantasy_league_id: league_id}
        }
      }),
      do: do_update_drafted(player_id, team_id, league_id)

  def update_unavailable_from_pick(%DraftPick{
        fantasy_player_id: player_id,
        fantasy_team_id: team_id,
        fantasy_team: %{fantasy_league_id: league_id}
      }),
      do: do_update_unavailable(player_id, team_id, league_id)

  def update_unavailable_from_pick(%InSeasonDraftPick{
        drafted_player_id: player_id,
        draft_pick_asset: %{
          fantasy_team_id: team_id,
          fantasy_team: %{fantasy_league_id: league_id}
        }
      }),
      do: do_update_unavailable(player_id, team_id, league_id)

  ## Helpers

  ## update_unavailable_from_pick

  defp do_update_drafted(player_id, team_id, league_id) do
    DraftQueue
    |> DraftQueue.by_player(player_id)
    |> DraftQueue.by_team(team_id)
    |> DraftQueue.by_league(league_id)
    |> DraftQueue.only_pending()
    |> DraftQueue.update_to_drafted()
  end

  ## update_unavailable_from_pick

  defp do_update_unavailable(player_id, drafting_team_id, league_id) do
    DraftQueue
    |> DraftQueue.by_player(player_id)
    |> DraftQueue.except_team(drafting_team_id)
    |> DraftQueue.by_league(league_id)
    |> DraftQueue.only_pending()
    |> DraftQueue.update_to_unavailable()
  end
end
