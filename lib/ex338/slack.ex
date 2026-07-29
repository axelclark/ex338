defmodule Ex338.Slack do
  @moduledoc """
  Posts notifications to a fantasy league's Slack alerts channel.

  Messages are delivered in the background by `Ex338.Workers.SlackMessageWorker`
  so a slow or failing Slack API never blocks a draft pick, and failures are
  retried. Leagues without a `slack_alerts_channel` are silently skipped, which
  is how a league opts out.
  """

  alias Ex338.FantasyLeagues.FantasyLeague
  alias Ex338.Slack.Client
  alias Ex338.Workers.SlackMessageWorker

  @doc """
  Enqueues a mrkdwn message for the league's alerts channel.

  Returns `{:ok, :no_channel}` when the league has no channel configured.
  """
  def notify_league(%FantasyLeague{slack_alerts_channel: nil}, _text), do: {:ok, :no_channel}

  def notify_league(%FantasyLeague{slack_alerts_channel: channel}, text) do
    %{channel: channel, text: text}
    |> SlackMessageWorker.new()
    |> Oban.insert()
  end

  @doc """
  Makes user-supplied text safe to interpolate into a mrkdwn message.

  `&`, `<` and `>` get the entity escapes Slack documents. The emphasis
  characters have no escape at all, and Slack pairs them positionally, so a
  stray `*` in a team name re-pairs with the bold markup around it and garbles
  the rest of the line — dropping them is the only way to keep the message
  readable. Team names are free text, so this is reachable by any owner.
  """
  def escape(text) do
    text
    |> to_string()
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace(~r/[*_`~]/, "")
  end

  @doc """
  A labelled Slack link, e.g. `<https://…/draft_picks|Div A draft page>`.
  """
  def link(url, label), do: "<#{url}|#{escape(label)}>"

  @doc """
  Posts a confirmation message to the league's channel and reports the result.

  Delivery normally happens in a background job, where a channel the bot can't
  post to fails with nothing but a log line. This runs inline so the commish
  finds out while the form is still in front of them.
  """
  def verify_channel(%FantasyLeague{slack_alerts_channel: nil}), do: {:error, "no channel set"}

  def verify_channel(%FantasyLeague{} = league) do
    text = "Draft alerts for #{escape(league.fantasy_league_name)} will post here."

    case Client.post_message(%{channel: league.slack_alerts_channel, text: text}) do
      {:ok, _body} -> :ok
      {:error, :missing_token} -> {:error, "no SLACK_BOT_TOKEN is configured"}
      {:error, reason} when is_binary(reason) -> {:error, reason}
      {:error, reason} -> {:error, inspect(reason)}
    end
  end
end
