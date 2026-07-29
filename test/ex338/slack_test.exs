defmodule Ex338.SlackTest do
  # Swaps the Slack client in application env, so it can't run alongside other
  # tests that post to Slack.
  use Ex338.DataCase, async: false

  alias Ex338.Slack
  alias Ex338.Slack.Client

  defmodule RejectingClient do
    @moduledoc false
    @behaviour Client

    @impl Client
    def post_message(_payload), do: {:error, "not_in_channel"}
  end

  defmodule TimingOutClient do
    @moduledoc false
    @behaviour Client

    @impl Client
    def post_message(_payload), do: {:error, :timeout}
  end

  describe "notify_league/2" do
    test "posts the message to the league's alerts channel" do
      league = insert(:fantasy_league, slack_alerts_channel: "C0338ALERTS")

      assert {:ok, _job} = Slack.notify_league(league, "Team A is on the clock")

      assert_receive {:slack_message, payload}
      assert payload.channel == "C0338ALERTS"
      assert payload.text == "Team A is on the clock"
      refute payload.unfurl_links
    end

    test "skips leagues without an alerts channel" do
      league = insert(:fantasy_league, slack_alerts_channel: nil)

      assert {:ok, :no_channel} = Slack.notify_league(league, "Team A is on the clock")

      refute_receive {:slack_message, _payload}
    end
  end

  describe "escape/1" do
    test "escapes the characters Slack treats as markup" do
      assert Slack.escape("Ampersand & <angles>") == "Ampersand &amp; &lt;angles&gt;"
    end

    test "drops emphasis characters that would re-pair with the surrounding markup" do
      # Slack has no escape for these, and pairs them positionally, so a stray one
      # in a team name garbles the rest of the line.
      assert Slack.escape("The *Best* _Team_ `x` ~y~") == "The Best Team x y"
    end
  end

  describe "verify_channel/1" do
    test "posts a confirmation to the channel" do
      league =
        insert(:fantasy_league, slack_alerts_channel: "C0338ALERTS", fantasy_league_name: "Div A")

      assert Slack.verify_channel(league) == :ok

      assert_receive {:slack_message, %{channel: "C0338ALERTS", text: text}}
      assert text =~ "Draft alerts for Div A will post here."
    end

    test "reports why Slack rejected the channel" do
      league = insert(:fantasy_league, slack_alerts_channel: "C0338ALERTS")

      with_client(RejectingClient, fn ->
        assert Slack.verify_channel(league) == {:error, "not_in_channel"}
      end)
    end

    test "reports a transport failure as a readable reason" do
      league = insert(:fantasy_league, slack_alerts_channel: "C0338ALERTS")

      with_client(TimingOutClient, fn ->
        assert Slack.verify_channel(league) == {:error, ":timeout"}
      end)
    end

    test "reports a league with no channel set" do
      league = insert(:fantasy_league, slack_alerts_channel: nil)

      assert Slack.verify_channel(league) == {:error, "no channel set"}
    end
  end

  defp with_client(client, fun) do
    previous = Application.get_env(:ex338, :slack_client)
    Application.put_env(:ex338, :slack_client, client)

    try do
      fun.()
    after
      Application.put_env(:ex338, :slack_client, previous)
    end
  end
end
