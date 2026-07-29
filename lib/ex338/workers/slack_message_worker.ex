defmodule Ex338.Workers.SlackMessageWorker do
  @moduledoc """
  Delivers a single message to a Slack channel.

  Slack errors that retrying can't fix (a channel the bot isn't in, a revoked
  token) cancel the job so it doesn't burn attempts; everything else is retried.

  Delivery is at-least-once on purpose. `chat.postMessage` takes no idempotency
  key, so a response lost to a timeout is indistinguishable from a message Slack
  never saw, and a retry can post a pick alert twice. For a draft alert a
  duplicate is noise while a miss means an owner loses their window, so retrying
  is the better failure.
  """
  use Oban.Worker,
    queue: :default,
    max_attempts: 3

  alias Ex338.Slack.Client

  require Logger

  # Slack returns an application error as a string in an HTTP 200 body. Those are
  # almost all configuration problems that a retry can't fix, so the default for a
  # string error is to cancel; only Slack-side congestion is worth another attempt.
  # Listing the transient ones rather than the permanent ones means an error we've
  # never seen cancels loudly instead of retrying three times and vanishing.
  # https://api.slack.com/methods/chat.postMessage#errors
  @transient_errors ~w(
    fatal_error
    internal_error
    ratelimited
    request_timeout
    service_unavailable
  )

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"channel" => channel, "text" => text}}) do
    payload = %{channel: channel, text: text, unfurl_links: false, unfurl_media: false}

    case Client.post_message(payload) do
      {:ok, _body} ->
        Logger.info("Sent Slack notification to #{channel}")
        :ok

      {:error, :missing_token} ->
        Logger.warning("No Slack bot token configured, skipping notification to #{channel}")
        {:cancel, :missing_token}

      {:error, error} when is_binary(error) and error not in @transient_errors ->
        Logger.error("Slack notification to #{channel} failed: #{error}")
        {:cancel, error}

      # Slack congestion and transport errors (timeouts, closed connections).
      {:error, reason} ->
        Logger.warning("Slack notification to #{channel} failed: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
