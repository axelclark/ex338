defmodule Ex338.Workers.InSeasonAutodraftWorkerTest do
  use Ex338.DataCase, async: true
  use Oban.Testing, repo: Ex338.Repo

  alias Ex338.CalendarAssistant

  describe "perform/1" do
    test "starts autodraft for a championship and a fantasy_league" do
      fantasy_league = insert(:fantasy_league)
      championship = insert(:championship)

      {:ok, _result} =
        perform_job(Ex338.Workers.InSeasonAutodraftWorker, %{
          fantasy_league_id: fantasy_league.id,
          championship_id: championship.id
        })
    end

    test "makes in season draft pick and schedules another job" do
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

      {:ok, result} =
        Oban.Testing.with_testing_mode(:manual, fn ->
          perform_job(Ex338.Workers.InSeasonAutodraftWorker, %{
            fantasy_league_id: league.id,
            championship_id: championship.id
          })
        end)

      assert result.drafted_player_id == player.id
      assert_enqueued(worker: Ex338.Workers.InSeasonAutodraftWorker)
    end

    test "stops scheduling next job after all picks complete" do
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

      _first_pick =
        insert(
          :in_season_draft_pick,
          position: 1,
          championship: championship,
          draft_pick_asset: pick_asset,
          drafted_player: player,
          drafted_at: CalendarAssistant.mins_from_now(-7)
        )

      {:ok, result} =
        Oban.Testing.with_testing_mode(:manual, fn ->
          perform_job(Ex338.Workers.InSeasonAutodraftWorker, %{
            fantasy_league_id: league.id,
            championship_id: championship.id
          })
        end)

      assert result == :in_season_draft_picks_complete
      refute_enqueued(worker: Ex338.Workers.InSeasonAutodraftWorker)
    end
  end
end
