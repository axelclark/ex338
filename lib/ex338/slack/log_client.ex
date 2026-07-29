defmodule Ex338.Slack.LogClient do
  @moduledoc """
  Logs messages instead of posting them — the Slack counterpart to
  `Swoosh.Adapters.Local` in dev.

  Without this, a dev server pointed at a copy of production data posts real
  pick alerts into real league channels, since each league row carries its own
  `slack_alerts_channel`. Call `Ex338.Slack.ApiClient` directly to smoke-test
  against Slack for real.
  """

  @behaviour Ex338.Slack.Client

  require Logger

  @impl Ex338.Slack.Client
  def post_message(%{channel: channel, text: text}) do
    Logger.info("Slack message to #{channel} (not sent outside prod):\n#{text}")

    {:ok, %{"ok" => true}}
  end
end
