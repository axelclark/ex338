defmodule Ex338.Slack.TestClient do
  @moduledoc """
  Test double for `Ex338.Slack.Client`.

  Sends the payload back to the test process so tests can assert with
  `assert_receive {:slack_message, payload}`, the same way
  `Swoosh.Adapters.Test` works for email.
  """

  @behaviour Ex338.Slack.Client

  @impl Ex338.Slack.Client
  def post_message(payload) do
    send(test_pid(), {:slack_message, payload})

    {:ok, %{"ok" => true}}
  end

  # Oban's inline testing mode runs jobs in the calling process, which is the
  # test itself for context tests but the LiveView process for LiveView tests.
  defp test_pid do
    [self() | Process.get(:"$callers", [])]
    |> Enum.reverse()
    |> hd()
  end
end
