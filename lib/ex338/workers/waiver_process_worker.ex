defmodule Ex338.Workers.WaiverProcessWorker do
  @moduledoc """
  Daily Oban cron worker that processes all pending waivers
  that have passed their `process_at` datetime.
  """
  use Oban.Worker,
    queue: :default,
    max_attempts: 3

  alias Ex338.Waivers

  @impl Oban.Worker
  def perform(_job) do
    Waivers.batch_process_all()

    :ok
  end
end
