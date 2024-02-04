defmodule Ex338.AutoDraftTest do
  use Ex338.DataCase, async: true

  import Swoosh.TestAssertions

  alias Ex338.AutoDraft
  alias Ex338.CalendarAssistant
  alias Ex338.DraftQueues.DraftQueue
  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.InSeasonDraftPicks.InSeasonDraftPick

  describe "make_picks_from_queues/1" do
    test "makes next draft pick from draft queue" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      drafted_player = insert(:fantasy_player)

      completed_pick =
        insert(
          :draft_pick,
          draft_position: 1.01,
          fantasy_player: drafted_player,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:10:02.857392], "Etc/UTC"),
          fantasy_team: team,
          fantasy_league: league
        )

      team_b = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)

      _next_pick =
        insert(
          :draft_pick,
          draft_position: 1.02,
          fantasy_team: team_b,
          fantasy_league: league
        )

      _drafted_queue =
        insert(
          :draft_queue,
          fantasy_team: team_b,
          fantasy_player: drafted_player,
          status: :drafted
        )

      _queue =
        insert(
          :draft_queue,
          fantasy_team: team_b,
          fantasy_player: player
        )

      [team_b_pick] = AutoDraft.make_picks_from_queues(completed_pick, [], 0)

      assert team_b_pick.fantasy_player_id == player.id

      subject =
        "338 Draft - #{league.fantasy_league_name}: #{team_b.team_name} selects #{player.player_name} (##{team_b_pick.draft_position})"

      assert_email_sent(subject: subject)
    end

    test "makes next two draft picks from draft queue" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      drafted_player = insert(:fantasy_player)

      completed_pick =
        insert(
          :draft_pick,
          draft_position: 1.01,
          fantasy_player: drafted_player,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:10:02.857392], "Etc/UTC"),
          fantasy_team: team,
          fantasy_league: league
        )

      team_b = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)
      player2 = insert(:fantasy_player)

      next_pick =
        insert(
          :draft_pick,
          draft_position: 1.02,
          fantasy_team: team_b,
          fantasy_league: league
        )

      _queue =
        insert(
          :draft_queue,
          fantasy_team: team_b,
          fantasy_player: player
        )

      third_pick =
        insert(
          :draft_pick,
          draft_position: 1.03,
          fantasy_team: team,
          fantasy_league: league
        )

      _queue2 =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player2
        )

      [team_b_pick, team_pick2] = AutoDraft.make_picks_from_queues(completed_pick, [], 0)

      assert team_b_pick.fantasy_player_id == player.id
      assert team_pick2.fantasy_player_id == player2.id

      subject =
        "338 Draft - #{league.fantasy_league_name}: #{team_b.team_name} selects #{player.player_name} (##{next_pick.draft_position})"

      assert_email_sent(subject: subject)

      subject2 =
        "338 Draft - #{league.fantasy_league_name}: #{team.team_name} selects #{player2.player_name} (##{third_pick.draft_position})"

      assert_email_sent(subject: subject2)
    end

    test "doesn't make draft pick when it is the last pick" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)
      drafted_player = insert(:fantasy_player)

      completed_pick =
        insert(
          :draft_pick,
          draft_position: 1.01,
          fantasy_player: drafted_player,
          fantasy_team: team,
          fantasy_league: league
        )

      assert AutoDraft.make_picks_from_queues(completed_pick, [], 0) == []
    end

    test "handles error (no drafted player in completed draft pick)" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league)

      completed_pick =
        insert(
          :draft_pick,
          draft_position: 1.01,
          fantasy_team: team,
          fantasy_league: league
        )

      team_b = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)

      _next_pick =
        insert(
          :draft_pick,
          draft_position: 1.02,
          fantasy_team: team_b,
          fantasy_league: league
        )

      _queue =
        insert(
          :draft_queue,
          fantasy_team: team_b,
          fantasy_player: player
        )

      assert AutoDraft.make_picks_from_queues(completed_pick, [], 0) == []
    end

    test "makes two draft picks when autodraft setting is on" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, autodraft_setting: "on")
      drafted_player = insert(:fantasy_player)

      completed_pick =
        insert(
          :draft_pick,
          draft_position: 1.01,
          fantasy_player: drafted_player,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:10:02.857392], "Etc/UTC"),
          fantasy_team: team,
          fantasy_league: league
        )

      player = insert(:fantasy_player)
      player2 = insert(:fantasy_player)

      _next_pick =
        insert(
          :draft_pick,
          draft_position: 1.02,
          fantasy_team: team,
          fantasy_league: league
        )

      _queue =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player
        )

      _third_pick =
        insert(
          :draft_pick,
          draft_position: 1.03,
          fantasy_team: team,
          fantasy_league: league
        )

      _queue2 =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player2
        )

      [team_pick1, team_pick2] = AutoDraft.make_picks_from_queues(completed_pick, [], 0)

      assert team_pick1.fantasy_player_id == player.id
      assert team_pick2.fantasy_player_id == player2.id
    end

    test "doesn't pick when autodraft setting is off" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, autodraft_setting: "off")
      drafted_player = insert(:fantasy_player)

      completed_pick =
        insert(
          :draft_pick,
          draft_position: 1.01,
          fantasy_player: drafted_player,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:10:02.857392], "Etc/UTC"),
          fantasy_team: team,
          fantasy_league: league
        )

      player = insert(:fantasy_player)
      player2 = insert(:fantasy_player)

      _next_pick =
        insert(
          :draft_pick,
          draft_position: 1.02,
          fantasy_team: team,
          fantasy_league: league
        )

      _queue =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player
        )

      _third_pick =
        insert(
          :draft_pick,
          draft_position: 1.03,
          fantasy_team: team,
          fantasy_league: league
        )

      _queue2 =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player2
        )

      assert AutoDraft.make_picks_from_queues(completed_pick, [], 0) == []
    end

    test "makes one draft pick when autodraft setting is single" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, autodraft_setting: "single")
      drafted_player = insert(:fantasy_player)

      completed_pick =
        insert(
          :draft_pick,
          draft_position: 1.01,
          fantasy_player: drafted_player,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:10:02.857392], "Etc/UTC"),
          fantasy_team: team,
          fantasy_league: league
        )

      player = insert(:fantasy_player)
      player2 = insert(:fantasy_player)

      _next_pick =
        insert(
          :draft_pick,
          draft_position: 1.02,
          fantasy_team: team,
          fantasy_league: league
        )

      _queue =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player
        )

      _third_pick =
        insert(
          :draft_pick,
          draft_position: 1.03,
          fantasy_team: team,
          fantasy_league: league
        )

      _queue2 =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player2
        )

      [team_pick1] = AutoDraft.make_picks_from_queues(completed_pick, [], 0)

      assert team_pick1.fantasy_player_id == player.id
    end

    test "makes draft pick when team over time limit is skipped" do
      league = insert(:fantasy_league, max_draft_hours: 1)
      team = insert(:fantasy_team, fantasy_league: league)
      drafted_player = insert(:fantasy_player)

      _completed_pick =
        insert(
          :draft_pick,
          draft_position: 1.01,
          fantasy_player: drafted_player,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:10:02.857392], "Etc/UTC"),
          fantasy_team: team,
          fantasy_league: league
        )

      drafted_player2 = insert(:fantasy_player)

      completed_pick2 =
        insert(
          :draft_pick,
          draft_position: 1.02,
          fantasy_player: drafted_player2,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 03:10:02.857392], "Etc/UTC"),
          fantasy_team: team,
          fantasy_league: league
        )

      _skipped_pick =
        insert(
          :draft_pick,
          draft_position: 1.03,
          fantasy_team: team,
          fantasy_league: league
        )

      team_b = insert(:fantasy_team, fantasy_league: league)
      player = insert(:fantasy_player)

      draft_pick =
        insert(
          :draft_pick,
          draft_position: 1.04,
          fantasy_team: team_b,
          fantasy_league: league
        )

      _queue2 =
        insert(
          :draft_queue,
          fantasy_team: team_b,
          fantasy_player: player
        )

      team_c = insert(:fantasy_team, fantasy_league: league)
      player_b = insert(:fantasy_player)

      _draft_pick2 =
        insert(
          :draft_pick,
          draft_position: 1.05,
          fantasy_team: team_c,
          fantasy_league: league
        )

      _queue3 =
        insert(
          :draft_queue,
          fantasy_team: team_c,
          fantasy_player: player_b
        )

      team_d = insert(:fantasy_team, fantasy_league: league)

      _no_pick =
        insert(
          :draft_pick,
          draft_position: 1.06,
          fantasy_team: team_d,
          fantasy_league: league
        )

      team_e = insert(:fantasy_team, fantasy_league: league)
      player_c = insert(:fantasy_player)

      _no_pick2 =
        insert(
          :draft_pick,
          draft_position: 1.07,
          fantasy_team: team_e,
          fantasy_league: league
        )

      _queue4 =
        insert(
          :draft_queue,
          fantasy_team: team_c,
          fantasy_player: player_c
        )

      [team_b_pick, team_c_pick] = AutoDraft.make_picks_from_queues(completed_pick2, [], 0)

      assert team_b_pick.fantasy_player_id == player.id
      assert team_c_pick.fantasy_player_id == player_b.id

      subject =
        "338 Draft - #{league.fantasy_league_name}: #{team_b.team_name} selects #{player.player_name} (##{draft_pick.draft_position})"

      assert_email_sent(subject: subject)
    end

    test "autodraft stops and emails owner if draft pick returns an error" do
      league = insert(:fantasy_league)
      team_a = insert(:fantasy_team, fantasy_league: league)
      _team_b = insert(:fantasy_team, fantasy_league: league)
      user = insert(:user)
      insert(:owner, user: user, fantasy_team: team_a)

      sport = insert(:sports_league)
      insert(:league_sport, sports_league: sport, fantasy_league: league)
      drafted_player = insert(:fantasy_player, sports_league: sport)
      player_b = insert(:fantasy_player, sports_league: sport)

      other_sport = insert(:sports_league)
      insert(:league_sport, sports_league: other_sport, fantasy_league: league)
      other_player = insert(:fantasy_player, sports_league: other_sport)

      completed_pick =
        insert(
          :draft_pick,
          draft_position: 1.01,
          fantasy_player: drafted_player,
          drafted_at: DateTime.from_naive!(~N[2018-09-21 01:10:02.857392], "Etc/UTC"),
          fantasy_team: team_a,
          fantasy_league: league
        )

      insert(:roster_position, fantasy_team: team_a, fantasy_player: drafted_player)

      _next_pick =
        insert(
          :draft_pick,
          draft_position: 1.02,
          fantasy_team: team_a,
          fantasy_league: league
        )

      _queue =
        insert(
          :draft_queue,
          fantasy_team: team_a,
          fantasy_player: player_b
        )

      _other_queue =
        insert(
          :draft_queue,
          fantasy_team: team_a,
          fantasy_player: other_player
        )

      assert AutoDraft.make_picks_from_queues(completed_pick, [], 0) == []

      subject = "There was an error with your autodraft queue"

      assert_email_sent(subject: subject)
    end
  end

  describe "in_season_picks_from_queues/2" do
    test "does NOT make first in season draft picks when draft has NOT started" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)

      championship =
        insert(:championship,
          sports_league: sport,
          max_draft_mins: 5,
          draft_starts_at: CalendarAssistant.mins_from_now(1)
        )

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      player = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      _first_pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          championship: championship,
          draft_pick_asset: pick_asset
        )

      _queue1 =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player
        )

      result = AutoDraft.in_season_draft_pick_from_queues(league.id, championship)

      assert result == {:ok, :draft_not_started}
    end

    test "returns :queues_not_loaded when no queue to draft from" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)

      championship =
        insert(:championship,
          sports_league: sport,
          max_draft_mins: 5,
          draft_starts_at: CalendarAssistant.mins_from_now(-1)
        )

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)

      _first_pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          championship: championship,
          draft_pick_asset: pick_asset
        )

      result = AutoDraft.in_season_draft_pick_from_queues(league.id, championship)

      assert result == {:ok, :queues_not_loaded}
    end

    test "makes first in season draft pick when draft has started and reorders queues" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)

      championship =
        insert(:championship,
          sports_league: sport,
          max_draft_mins: 5,
          draft_starts_at: CalendarAssistant.mins_from_now(-1)
        )

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      player = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      first_pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          championship: championship,
          draft_pick_asset: pick_asset
        )

      _queue1 =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player
        )

      team_b = insert(:fantasy_team, fantasy_league: league)
      next_pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      next_pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: next_pick)
      player2 = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      _second_pick =
        insert(
          :in_season_draft_pick,
          position: 2,
          fantasy_league: league,
          championship: championship,
          draft_pick_asset: next_pick_asset
        )

      unavailable_queue =
        insert(
          :draft_queue,
          order: 1,
          fantasy_team: team_b,
          fantasy_player: player
        )

      new_top_queue =
        insert(
          :draft_queue,
          order: 2,
          fantasy_team: team_b,
          fantasy_player: player2
        )

      {:ok, pick} = AutoDraft.in_season_draft_pick_from_queues(league.id, championship)

      assert pick.drafted_player_id == player.id
      assert Repo.get!(DraftQueue, unavailable_queue.id).status == :unavailable
      assert Repo.get!(DraftQueue, new_top_queue.id).order == 1

      subject =
        "338 Draft - #{league.fantasy_league_name}: #{team.team_name} selects #{player.player_name} (##{first_pick.position})"

      assert_email_sent(subject: subject)
    end

    test "makes one in season draft pick when team over time limit is skipped" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)

      championship =
        insert(:championship,
          sports_league: sport,
          max_draft_mins: 5,
          draft_starts_at: CalendarAssistant.mins_from_now(-8)
        )

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      player = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      _completed_pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          championship: championship,
          draft_pick_asset: pick_asset,
          drafted_player: player,
          drafted_at: CalendarAssistant.mins_from_now(-7)
        )

      next_pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      next_pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: next_pick)

      insert(
        :in_season_draft_pick,
        position: 2,
        fantasy_league: league,
        championship: championship,
        draft_pick_asset: next_pick_asset
      )

      team_b = insert(:fantasy_team, fantasy_league: league)
      future_pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)

      future_pick_asset =
        insert(:roster_position, fantasy_team: team_b, fantasy_player: future_pick)

      _future_pick =
        insert(
          :in_season_draft_pick,
          position: 3,
          fantasy_league: league,
          championship: championship,
          draft_pick_asset: future_pick_asset
        )

      player_to_draft = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      _queue =
        insert(
          :draft_queue,
          fantasy_team: team_b,
          fantasy_player: player_to_draft
        )

      future_pick2 = insert(:fantasy_player, draft_pick: true, sports_league: sport)

      future_pick_asset2 =
        insert(:roster_position, fantasy_team: team_b, fantasy_player: future_pick2)

      future_pick2 =
        insert(
          :in_season_draft_pick,
          position: 4,
          fantasy_league: league,
          championship: championship,
          draft_pick_asset: future_pick_asset2
        )

      player_to_draft2 = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      _queue2 =
        insert(
          :draft_queue,
          fantasy_team: team_b,
          fantasy_player: player_to_draft2
        )

      {:ok, result} = AutoDraft.in_season_draft_pick_from_queues(league.id, championship)

      assert result.drafted_player_id == player_to_draft.id
      assert Repo.get!(InSeasonDraftPick, future_pick2.id).drafted_player_id == nil
    end

    test "handles autodraft settings during in season draft" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)

      championship =
        insert(:championship,
          sports_league: sport,
          max_draft_mins: 5,
          draft_starts_at: CalendarAssistant.mins_from_now(-8)
        )

      team = insert(:fantasy_team, fantasy_league: league, autodraft_setting: "off")
      pick = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      player = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      _completed_pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          championship: championship,
          draft_pick_asset: pick_asset,
          drafted_player: player,
          drafted_at: CalendarAssistant.mins_from_now(-7)
        )

      next_pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      next_pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: next_pick)
      player_to_draft = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      skipped_pick =
        insert(
          :in_season_draft_pick,
          position: 2,
          fantasy_league: league,
          championship: championship,
          draft_pick_asset: next_pick_asset
        )

      _queue =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player_to_draft
        )

      team_b = insert(:fantasy_team, fantasy_league: league, autodraft_setting: "single")
      future_pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)

      future_pick_asset =
        insert(:roster_position, fantasy_team: team_b, fantasy_player: future_pick)

      _autodraft_pick =
        insert(
          :in_season_draft_pick,
          position: 3,
          fantasy_league: league,
          championship: championship,
          draft_pick_asset: future_pick_asset
        )

      _queue =
        insert(
          :draft_queue,
          fantasy_team: team_b,
          fantasy_player: player_to_draft
        )

      {:ok, result} = AutoDraft.in_season_draft_pick_from_queues(league.id, championship)

      assert result.draft_pick_asset_id == future_pick_asset.id
      assert result.drafted_player_id == player_to_draft.id
      assert Repo.get!(InSeasonDraftPick, skipped_pick.id).drafted_player_id == nil
      assert Repo.get!(FantasyTeam, team_b.id).autodraft_setting == :off
    end

    test "returns :picks_complete when draft has ended" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)

      championship =
        insert(:championship,
          sports_league: sport,
          max_draft_mins: 5,
          draft_starts_at: CalendarAssistant.mins_from_now(-8)
        )

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      player = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      _completed_pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          championship: championship,
          draft_pick_asset: pick_asset,
          drafted_player: player,
          drafted_at: CalendarAssistant.mins_from_now(-7)
        )

      result = AutoDraft.in_season_draft_pick_from_queues(league.id, championship)

      assert result == {:ok, :in_season_draft_picks_complete}
    end
  end
end
