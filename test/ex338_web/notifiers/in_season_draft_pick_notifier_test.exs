defmodule Ex338Web.InSeasonDraftPickNotifierTest do
  use Ex338.DataCase, async: true

  alias Ex338.CalendarAssistant
  alias Ex338Web.InSeasonDraftPickNotifier

  describe "send_update/1" do
    test "posts the pick to the league's Slack alerts channel" do
      league = insert(:fantasy_league, slack_alerts_channel: "C0338ALERTS")
      sports_league = insert(:sports_league, abbrev: "CBB")

      championship =
        insert(:championship,
          title: "March Madness",
          in_season_draft: true,
          sports_league: sports_league,
          draft_starts_at: CalendarAssistant.mins_from_now(-30)
        )

      team = insert(:fantasy_team, fantasy_league: league, team_name: "Sharks")
      other_team = insert(:fantasy_team, fantasy_league: league, team_name: "Bears")
      drafted_player = insert(:fantasy_player, player_name: "Duke", sports_league: sports_league)

      pick =
        insert(:in_season_draft_pick,
          position: 1,
          championship: championship,
          drafted_at: CalendarAssistant.mins_from_now(-1),
          drafted_player: drafted_player,
          draft_pick_asset: draft_pick_asset(team, sports_league)
        )

      insert(:in_season_draft_pick,
        position: 2,
        championship: championship,
        draft_pick_asset: draft_pick_asset(other_team, sports_league)
      )

      InSeasonDraftPickNotifier.send_update(pick)

      assert_receive {:slack_message, %{channel: "C0338ALERTS", text: text}}
      assert text =~ "*Sharks selected Duke (CBB)* — pick #1"
      assert text =~ "On the clock: Bears."
      assert text =~ "/championships/#{championship.id}|March Madness draft page>"

      # The channel is the draft's history, so the message doesn't recap it.
      refute text =~ "Latest Picks"
      refute text =~ "Next Up"
    end

    test "skips Slack when the league has no alerts channel" do
      league = insert(:fantasy_league, slack_alerts_channel: nil)
      sports_league = insert(:sports_league)
      championship = insert(:championship, in_season_draft: true, sports_league: sports_league)
      team = insert(:fantasy_team, fantasy_league: league)

      pick =
        insert(:in_season_draft_pick,
          position: 1,
          championship: championship,
          drafted_at: CalendarAssistant.mins_from_now(-1),
          drafted_player: insert(:fantasy_player, sports_league: sports_league),
          draft_pick_asset: draft_pick_asset(team, sports_league)
        )

      InSeasonDraftPickNotifier.send_update(pick)

      refute_receive {:slack_message, _payload}
    end
  end

  defp draft_pick_asset(fantasy_team, sports_league) do
    insert(:roster_position,
      fantasy_team: fantasy_team,
      fantasy_player: insert(:fantasy_player, draft_pick: true, sports_league: sports_league)
    )
  end
end
