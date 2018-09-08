defmodule Ex338.AutoDraftTest do
  use Ex338.DataCase, async: true

  import Swoosh.TestAssertions

  alias Ex338.{AutoDraft}

  describe "make_picks_from_queues/1" do
    test "makes next inseason pick from draft queue" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      drafted_player = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      completed_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset,
          championship: championship,
          position: 1,
          drafted_player: drafted_player
        )

      team_b = insert(:fantasy_team, fantasy_league: league)
      pick_b = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset_b = insert(:roster_position, fantasy_team: team_b, fantasy_player: pick_b)
      player = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      _next_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset_b,
          championship: championship,
          position: 2
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

      [team_b_pick] = AutoDraft.make_picks_from_queues(completed_pick)

      assert team_b_pick.drafted_player_id == player.id

      subject =
        "338 Draft: #{team_b.team_name} selects #{player.player_name} (##{team_b_pick.position})"

      assert_email_sent(subject: subject)
    end

    test "makes next draft pick from draft queue" do
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

      [team_b_pick] = AutoDraft.make_picks_from_queues(completed_pick)

      assert team_b_pick.fantasy_player_id == player.id

      subject =
        "338 Draft: #{team_b.team_name} selects #{player.player_name} (##{
          team_b_pick.draft_position
        })"

      assert_email_sent(subject: subject)
    end

    test "makes next two inseason picks from draft queue" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)
      drafted_player = insert(:fantasy_player, draft_pick: false, sports_league: sport)
      player = insert(:fantasy_player, draft_pick: false, sports_league: sport)
      player2 = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick2 = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      pick_asset2 = insert(:roster_position, fantasy_team: team, fantasy_player: pick2)

      completed_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset,
          championship: championship,
          position: 1,
          drafted_player: drafted_player
        )

      _third_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset2,
          championship: championship,
          position: 3
        )

      _unavailable_queue =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player,
          status: :pending
        )

      _pick2_queue =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player2,
          status: :pending
        )

      team_b = insert(:fantasy_team, fantasy_league: league)
      pick_b = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset_b = insert(:roster_position, fantasy_team: team_b, fantasy_player: pick_b)

      _next_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset_b,
          championship: championship,
          position: 2
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
          fantasy_player: player,
          status: :pending
        )

      [team_b_pick, team_pick2] = AutoDraft.make_picks_from_queues(completed_pick)

      assert team_b_pick.drafted_player_id == player.id
      assert team_pick2.drafted_player_id == player2.id

      subject =
        "338 Draft: #{team_b.team_name} selects #{player.player_name} (##{team_b_pick.position})"

      assert_email_sent(subject: subject)

      subject2 =
        "338 Draft: #{team.team_name} selects #{player2.player_name} (##{team_pick2.position})"

      assert_email_sent(subject: subject2)
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

      [team_b_pick, team_pick2] = AutoDraft.make_picks_from_queues(completed_pick)

      assert team_b_pick.fantasy_player_id == player.id
      assert team_pick2.fantasy_player_id == player2.id

      subject =
        "338 Draft: #{team_b.team_name} selects #{player.player_name} (##{
          next_pick.draft_position
        })"

      assert_email_sent(subject: subject)

      subject2 =
        "338 Draft: #{team.team_name} selects #{player2.player_name} (##{
          third_pick.draft_position
        })"

      assert_email_sent(subject: subject2)
    end

    test "doesn't make inseason pick when it is the last pick" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      drafted_player = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      completed_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset,
          championship: championship,
          position: 1,
          drafted_player: drafted_player
        )

      assert AutoDraft.make_picks_from_queues(completed_pick) == []
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

      assert AutoDraft.make_picks_from_queues(completed_pick) == []
    end

    test "doesn't make inseason pick when no queue" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      drafted_player = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      completed_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset,
          championship: championship,
          position: 1,
          drafted_player: drafted_player
        )

      team_b = insert(:fantasy_team, fantasy_league: league)
      pick_b = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset_b = insert(:roster_position, fantasy_team: team_b, fantasy_player: pick_b)

      _next_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset_b,
          championship: championship,
          position: 2
        )

      assert AutoDraft.make_picks_from_queues(completed_pick) == []
    end

    test "handles error (no drafted player in completed inseason pick)" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)

      team = insert(:fantasy_team, fantasy_league: league)
      pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      drafted_player = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      completed_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset,
          championship: championship,
          position: 1
        )

      team_b = insert(:fantasy_team, fantasy_league: league)
      pick_b = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset_b = insert(:roster_position, fantasy_team: team_b, fantasy_player: pick_b)

      _next_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset_b,
          championship: championship,
          position: 2
        )

      _queue =
        insert(
          :draft_queue,
          fantasy_team: team_b,
          fantasy_player: drafted_player
        )

      assert AutoDraft.make_picks_from_queues(completed_pick) == []
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

      assert AutoDraft.make_picks_from_queues(completed_pick) == []
    end

    test "makes two inseason draft picks when autodraft setting is on" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)
      drafted_player = insert(:fantasy_player, draft_pick: false, sports_league: sport)
      player2 = insert(:fantasy_player, draft_pick: false, sports_league: sport)
      player3 = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      team = insert(:fantasy_team, fantasy_league: league, autodraft_setting: "on")
      pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick2 = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick3 = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      pick_asset2 = insert(:roster_position, fantasy_team: team, fantasy_player: pick2)
      pick_asset3 = insert(:roster_position, fantasy_team: team, fantasy_player: pick3)

      completed_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset,
          championship: championship,
          position: 1,
          drafted_player: drafted_player
        )

      _second_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset2,
          championship: championship,
          position: 2
        )

      _third_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset3,
          championship: championship,
          position: 3
        )

      _pick2_queue =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player2,
          status: :pending
        )

      _pick3_queue =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player3,
          status: :pending
        )

      [team_pick2, team_pick3] = AutoDraft.make_picks_from_queues(completed_pick)

      assert team_pick2.drafted_player_id == player2.id
      assert team_pick3.drafted_player_id == player3.id
    end

    test "makes no inseason draft picks when autodraft setting is off" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)
      drafted_player = insert(:fantasy_player, draft_pick: false, sports_league: sport)
      player2 = insert(:fantasy_player, draft_pick: false, sports_league: sport)
      player3 = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      team = insert(:fantasy_team, fantasy_league: league, autodraft_setting: "off")
      pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick2 = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick3 = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      pick_asset2 = insert(:roster_position, fantasy_team: team, fantasy_player: pick2)
      pick_asset3 = insert(:roster_position, fantasy_team: team, fantasy_player: pick3)

      completed_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset,
          championship: championship,
          position: 1,
          drafted_player: drafted_player
        )

      _second_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset2,
          championship: championship,
          position: 2
        )

      _third_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset3,
          championship: championship,
          position: 3
        )

      _pick2_queue =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player2,
          status: :pending
        )

      _pick3_queue =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player3,
          status: :pending
        )

      assert AutoDraft.make_picks_from_queues(completed_pick) == []
    end

    test "makes one inseason draft pick when autodraft setting is single" do
      league = insert(:fantasy_league)
      sport = insert(:sports_league)
      championship = insert(:championship, sports_league: sport)
      drafted_player = insert(:fantasy_player, draft_pick: false, sports_league: sport)
      player2 = insert(:fantasy_player, draft_pick: false, sports_league: sport)
      player3 = insert(:fantasy_player, draft_pick: false, sports_league: sport)

      team = insert(:fantasy_team, fantasy_league: league, autodraft_setting: "single")
      pick = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick2 = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick3 = insert(:fantasy_player, draft_pick: true, sports_league: sport)
      pick_asset = insert(:roster_position, fantasy_team: team, fantasy_player: pick)
      pick_asset2 = insert(:roster_position, fantasy_team: team, fantasy_player: pick2)
      pick_asset3 = insert(:roster_position, fantasy_team: team, fantasy_player: pick3)

      completed_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset,
          championship: championship,
          position: 1,
          drafted_player: drafted_player
        )

      _second_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset2,
          championship: championship,
          position: 2
        )

      _third_pick =
        insert(
          :in_season_draft_pick,
          draft_pick_asset: pick_asset3,
          championship: championship,
          position: 3
        )

      _pick2_queue =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player2,
          status: :pending
        )

      _pick3_queue =
        insert(
          :draft_queue,
          fantasy_team: team,
          fantasy_player: player3,
          status: :pending
        )

      [team_pick2] = AutoDraft.make_picks_from_queues(completed_pick)

      assert team_pick2.drafted_player_id == player2.id
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

      [team_pick1, team_pick2] = AutoDraft.make_picks_from_queues(completed_pick)

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

      assert AutoDraft.make_picks_from_queues(completed_pick) == []
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

      [team_pick1] = AutoDraft.make_picks_from_queues(completed_pick)

      assert team_pick1.fantasy_player_id == player.id
    end
  end
end
