defmodule Ex338Web.Api.V1.DraftQueueJSON do
  def index(%{draft_queues: draft_queues}) do
    %{draft_queues: Enum.map(draft_queues, &draft_queue_data/1)}
  end

  def show(%{draft_queue: draft_queue}) do
    %{draft_queue: draft_queue_data(draft_queue)}
  end

  defp draft_queue_data(draft_queue) do
    %{
      id: draft_queue.id,
      order: draft_queue.order,
      status: draft_queue.status,
      fantasy_team: %{
        id: draft_queue.fantasy_team.id,
        team_name: draft_queue.fantasy_team.team_name
      },
      fantasy_player: player_data(draft_queue.fantasy_player)
    }
  end

  defp player_data(%{id: id} = player) do
    %{id: id, player_name: player.player_name}
  end

  defp player_data(_), do: nil
end
