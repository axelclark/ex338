defmodule Ex338.Slack.Client do
  @moduledoc """
  Behaviour for posting to the Slack Web API, swapped out in test via the
  `:slack_client` application env.
  """

  @callback post_message(map()) :: {:ok, map()} | {:error, term()}

  def post_message(payload), do: impl().post_message(payload)

  defp impl do
    Application.get_env(:ex338, :slack_client, Ex338.Slack.ApiClient)
  end
end
