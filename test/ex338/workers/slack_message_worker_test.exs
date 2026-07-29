defmodule Ex338.Workers.SlackMessageWorkerTest do
  # Swaps the Slack client in application env, so it can't run alongside other
  # tests that post to Slack.
  use Ex338.DataCase, async: false

  import ExUnit.CaptureLog

  alias Ex338.Slack.Client
  alias Ex338.Workers.SlackMessageWorker

  defmodule PermanentErrorClient do
    @moduledoc false
    @behaviour Client

    @impl Client
    def post_message(_payload), do: {:error, "channel_not_found"}
  end

  defmodule TransientErrorClient do
    @moduledoc false
    @behaviour Client

    @impl Client
    def post_message(_payload), do: {:error, :timeout}
  end

  defmodule UnlistedErrorClient do
    @moduledoc false
    @behaviour Client

    @impl Client
    def post_message(_payload), do: {:error, "invalid_arguments"}
  end

  defmodule RateLimitedClient do
    @moduledoc false
    @behaviour Client

    @impl Client
    def post_message(_payload), do: {:error, "ratelimited"}
  end

  defmodule MissingTokenClient do
    @moduledoc false
    @behaviour Client

    @impl Client
    def post_message(_payload), do: {:error, :missing_token}
  end

  describe "perform/1" do
    test "posts the message to Slack" do
      assert perform(%{"channel" => "C0338ALERTS", "text" => "Team A selected Player X"}) == :ok

      assert_receive {:slack_message, payload}
      assert payload.channel == "C0338ALERTS"
    end

    test "cancels the job when retrying can't fix the error" do
      use_client(PermanentErrorClient)

      assert capture_log(fn ->
               assert perform(%{"channel" => "C0338ALERTS", "text" => "hi"}) ==
                        {:cancel, "channel_not_found"}
             end) =~ "channel_not_found"
    end

    test "cancels the job when no bot token is configured" do
      use_client(MissingTokenClient)

      assert capture_log(fn ->
               assert perform(%{"channel" => "C0338ALERTS", "text" => "hi"}) ==
                        {:cancel, :missing_token}
             end) =~ "No Slack bot token configured"
    end

    test "retries the job when Slack fails for a transient reason" do
      use_client(TransientErrorClient)

      assert capture_log(fn ->
               assert perform(%{"channel" => "C0338ALERTS", "text" => "hi"}) == {:error, :timeout}
             end) =~ "timeout"
    end

    test "cancels on a Slack error that isn't a known transient one" do
      # Slack has far more application errors than any allowlist would track, and
      # none of them get better on a retry.
      use_client(UnlistedErrorClient)

      assert capture_log(fn ->
               assert perform(%{"channel" => "C0338ALERTS", "text" => "hi"}) ==
                        {:cancel, "invalid_arguments"}
             end) =~ "invalid_arguments"
    end

    test "retries when Slack rate limits the app" do
      use_client(RateLimitedClient)

      assert capture_log(fn ->
               assert perform(%{"channel" => "C0338ALERTS", "text" => "hi"}) ==
                        {:error, "ratelimited"}
             end) =~ "ratelimited"
    end
  end

  defp perform(args) do
    SlackMessageWorker.perform(%Oban.Job{args: args})
  end

  defp use_client(client) do
    previous = Application.get_env(:ex338, :slack_client)
    Application.put_env(:ex338, :slack_client, client)
    on_exit(fn -> Application.put_env(:ex338, :slack_client, previous) end)
  end
end
