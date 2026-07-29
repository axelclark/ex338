defmodule Ex338.Slack.ApiClient do
  @moduledoc """
  Posts to `chat.postMessage` with the bot token in `:slack_bot_token`.

  Slack answers with HTTP 200 even for application errors, so a successful
  response still has to be checked for `"ok" => true`.
  """

  @behaviour Ex338.Slack.Client

  @url "https://slack.com/api/chat.postMessage"

  @impl Ex338.Slack.Client
  def post_message(payload) do
    case Application.get_env(:ex338, :slack_bot_token) do
      token when is_binary(token) and token != "" -> post(payload, token)
      _missing -> {:error, :missing_token}
    end
  end

  defp post(payload, token) do
    case Req.post(@url, json: payload, auth: {:bearer, token}, receive_timeout: 10_000) do
      {:ok, %Req.Response{status: 200, body: %{"ok" => true} = body}} -> {:ok, body}
      {:ok, %Req.Response{status: 200, body: %{"error" => error}}} -> {:error, error}
      {:ok, %Req.Response{status: status}} -> {:error, {:unexpected_status, status}}
      {:error, reason} -> {:error, reason}
    end
  end
end
