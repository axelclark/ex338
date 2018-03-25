defmodule Ex338.AutoDraftTest do
  use Ex338.DataCase, async: true

  import Swoosh.TestAssertions

  alias Ex338.{AutoDraft}

  describe "call" do
    test "makes next pick from draft queue" do
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

    test "makes next two picks from draft queue" do
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

    test "doesn't make pick when it is the last pick" do
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

    test "doesn't make pick when no queue" do
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

    test "handles error (no drafted player in completed pick)" do
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
  end
end
