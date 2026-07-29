defmodule Ex338Web.DraftPickNotifierTest do
  use Ex338.DataCase, async: true

  alias Ex338.CalendarAssistant
  alias Ex338Web.DraftPickNotifier

  describe "send_update/1" do
    test "posts the pick to the league's Slack alerts channel" do
      league = insert(:fantasy_league, slack_alerts_channel: "C0338ALERTS")
      team = insert(:fantasy_team, fantasy_league: league, team_name: "Sharks")
      other_team = insert(:fantasy_team, fantasy_league: league, team_name: "Bears")

      player =
        insert(:fantasy_player,
          player_name: "Tiger Woods",
          sports_league: insert(:sports_league, abbrev: "PGA")
        )

      draft_pick =
        insert(:draft_pick,
          draft_position: 1.01,
          drafted_at: CalendarAssistant.mins_from_now(-1),
          fantasy_league: league,
          fantasy_team: team,
          fantasy_player: player
        )

      insert(:draft_pick, draft_position: 1.02, fantasy_league: league, fantasy_team: other_team)

      DraftPickNotifier.send_update(draft_pick)

      assert_receive {:slack_message, %{channel: "C0338ALERTS", text: text}}
      assert text =~ "*Sharks selected Tiger Woods (PGA)* — pick #1.01"
      assert text =~ "On the clock: Bears."

      assert text =~
               "/fantasy_leagues/#{league.id}/draft_picks|#{league.fantasy_league_name} draft page>"

      # The channel is the draft's history, so the message doesn't recap it.
      refute text =~ "Latest Picks"
      refute text =~ "Next Up"
    end

    test "says the draft is over when no picks remain" do
      league = insert(:fantasy_league, slack_alerts_channel: "C0338ALERTS")
      team = insert(:fantasy_team, fantasy_league: league, team_name: "Sharks")

      draft_pick =
        insert(:draft_pick,
          draft_position: 1.01,
          drafted_at: CalendarAssistant.mins_from_now(-1),
          fantasy_league: league,
          fantasy_team: team,
          fantasy_player: insert(:fantasy_player)
        )

      DraftPickNotifier.send_update(draft_pick)

      assert_receive {:slack_message, %{text: text}}
      assert text =~ "That wraps up the draft!"
    end

    test "emails a skipped team's open pick under Next Up and the new pick under Latest Picks" do
      league = insert(:fantasy_league, slack_alerts_channel: "C0338ALERTS")
      alpha = insert(:fantasy_team, fantasy_league: league, team_name: "Alpha")
      beta = insert(:fantasy_team, fantasy_league: league, team_name: "Beta")
      gamma = insert(:fantasy_team, fantasy_league: league, team_name: "Gamma")

      insert(:draft_pick,
        draft_position: 1.01,
        drafted_at: CalendarAssistant.mins_from_now(-3),
        fantasy_league: league,
        fantasy_team: alpha,
        fantasy_player: insert(:fantasy_player, player_name: "PlayerA")
      )

      # Beta ran out the clock, so 1.02 stays open behind the pick just made.
      insert(:draft_pick, draft_position: 1.02, fantasy_league: league, fantasy_team: beta)

      gamma_pick =
        insert(:draft_pick,
          draft_position: 1.03,
          drafted_at: CalendarAssistant.mins_from_now(-1),
          fantasy_league: league,
          fantasy_team: gamma,
          fantasy_player: insert(:fantasy_player, player_name: "PlayerZ")
        )

      assert {:ok, email} = DraftPickNotifier.send_update(gamma_pick)

      [_intro, latest, next_up] =
        String.split(email.html_body, ["<h3>Latest Picks:</h3>", "<h3>Next Up:</h3>"])

      assert latest =~ "PlayerA"
      assert latest =~ "PlayerZ"
      assert next_up =~ "Beta"
      refute next_up =~ "PlayerZ"
    end

    test "skips Slack when the league has no alerts channel" do
      league = insert(:fantasy_league, slack_alerts_channel: nil)
      team = insert(:fantasy_team, fantasy_league: league)

      draft_pick =
        insert(:draft_pick,
          drafted_at: CalendarAssistant.mins_from_now(-1),
          fantasy_league: league,
          fantasy_team: team,
          fantasy_player: insert(:fantasy_player)
        )

      DraftPickNotifier.send_update(draft_pick)

      refute_receive {:slack_message, _payload}
    end
  end

  describe "send_error/1" do
    test "emails the owner and admins without posting to the league channel" do
      # One team's queue failing isn't league news, so it stays out of Slack even
      # when the league has an alerts channel.
      league = insert(:fantasy_league, slack_alerts_channel: "C0338ALERTS")
      team = insert(:fantasy_team, fantasy_league: league, team_name: "Sharks")
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)
      player = insert(:fantasy_player, player_name: "Tiger Woods")
      draft_pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team)

      changeset =
        draft_pick
        |> Ecto.Changeset.cast(%{fantasy_player_id: player.id}, [:fantasy_player_id])
        |> Ecto.Changeset.add_error(:fantasy_player_id, "has already been drafted")

      assert {:ok, email} = DraftPickNotifier.send_error(changeset)
      assert email.subject == "There was an error with your autodraft queue"
      assert {user.name, user.email} in email.to
      assert email.html_body =~ "Tiger Woods"

      refute_receive {:slack_message, _payload}
    end

    test "emails the owner even when the pick has been deleted" do
      # The email is what tells an owner their queue broke, so it must not depend
      # on reloading the pick.
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      user = insert(:user)
      insert(:owner, fantasy_team: team, user: user)
      player = insert(:fantasy_player)
      draft_pick = insert(:draft_pick, fantasy_league: league, fantasy_team: team)

      changeset =
        draft_pick
        |> Ecto.Changeset.cast(%{fantasy_player_id: player.id}, [:fantasy_player_id])
        |> Ecto.Changeset.add_error(:fantasy_player_id, "has already been drafted")

      Repo.delete!(draft_pick)

      assert {:ok, email} = DraftPickNotifier.send_error(changeset)
      assert {user.name, user.email} in email.to
    end
  end
end
