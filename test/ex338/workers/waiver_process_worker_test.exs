defmodule Ex338.Workers.WaiverProcessWorkerTest do
  use Ex338.DataCase, async: true
  use Oban.Testing, repo: Ex338.Repo

  alias Ex338.Workers.WaiverProcessWorker

  describe "perform/1" do
    test "processes pending waivers that are ready" do
      league = insert(:fantasy_league)
      team = insert(:fantasy_team, fantasy_league: league, waiver_position: 1)
      player = insert(:fantasy_player)
      sports_league = insert(:sports_league)
      insert(:league_sport, fantasy_league: league, sports_league: sports_league)
      insert(:championship, sports_league: sports_league)

      insert(:waiver,
        fantasy_team: team,
        add_fantasy_player: player,
        status: "pending",
        process_at: DateTime.add(DateTime.utc_now(), -86400)
      )

      assert :ok = perform_job(WaiverProcessWorker, %{})
    end

    test "succeeds when there are no pending waivers" do
      assert :ok = perform_job(WaiverProcessWorker, %{})
    end
  end
end
