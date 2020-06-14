defmodule Ex338.DraftQueues.Admin do
  @moduledoc false

  alias Ex338.{DraftPicks.DraftPick, DraftQueues.DraftQueue, InSeasonDraftPicks.InSeasonDraftPick}
  alias Ecto.Multi

  def reorder_for_league(league_queues) do
    league_queues
    |> group_queues_by_team()
    |> update_queues_for_teams()
  end

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

  ## reorder_for_league

  defp group_queues_by_team(queues), do: Enum.group_by(queues, & &1.fantasy_team_id)

  defp update_queues_for_teams(team_queues) do
    Enum.reduce(team_queues, Multi.new(), &update_queues_for_team/2)
  end

  defp update_queues_for_team({_team_id, queues}, multi) do
    queues
    |> Enum.sort_by(& &1.order)
    |> Enum.with_index(1)
    |> Enum.reduce(Multi.new(), &update_draft_queue_order/2)
    |> Multi.prepend(multi)
  end

  defp update_draft_queue_order({%DraftQueue{id: id}, index}, multi) do
    multi_name = String.to_atom("queue_id_" <> Integer.to_string(id))

    update_query =
      DraftQueue
      |> DraftQueue.by_id(id)
      |> DraftQueue.update_order(index)

    Multi.update_all(multi, multi_name, update_query, [])
  end

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
