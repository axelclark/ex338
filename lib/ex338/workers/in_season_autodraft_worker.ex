defmodule Ex338.Workers.InSeasonAutodraftWorker do
  use Oban.Worker,
    max_attempts: 1

  alias Ex338.{AutoDraft, Championships}

  @ten_seconds 10

  @impl Oban.Worker
  def perform(%Oban.Job{} = job) do
    %{args: %{"fantasy_league_id" => fantasy_league_id, "championship_id" => championship_id}} =
      job

    case make_in_season_draft_pick_from_queues(fantasy_league_id, championship_id) do
      {:ok, :in_season_draft_picks_complete} ->
        {:ok, :in_season_draft_picks_complete}

      result ->
        schedule_next_job(job)
        result
    end
  end

  defp make_in_season_draft_pick_from_queues(fantasy_league_id, championship_id) do
    championship = Championships.get_championship_by_league(championship_id, fantasy_league_id)
    AutoDraft.in_season_draft_pick_from_queues(fantasy_league_id, championship)
  end

  defp schedule_next_job(job) do
    job.args
    |> new(schedule_in: @ten_seconds)
    |> Oban.insert()
  end
end
