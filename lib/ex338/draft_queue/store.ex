defmodule Ex338.DraftQueue.Store do
  @moduledoc false

  alias Ex338.{Repo, DraftQueue, FantasyTeam}

  def create_draft_queue(attrs \\ %{}) do
    updated_attrs = add_order_from_queue_count(attrs)

    %DraftQueue{}
    |> DraftQueue.changeset(updated_attrs)
    |> Repo.insert()
  end

  ## Helpers

  ## create_draft_queue

  defp add_order_from_queue_count(%{"order" => _order} = attrs), do: attrs

  defp add_order_from_queue_count(%{"fantasy_team_id" => team_id} = attrs) do
    queue_count = FantasyTeam.Store.count_pending_draft_queues(team_id)

    Map.put(attrs, "order", queue_count + 1)
  end

  defp add_order_from_queue_count(attrs), do: attrs
end
