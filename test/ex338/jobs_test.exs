defmodule Ex338.JobsTest do
  use Ex338.DataCase, async: true

  use Oban.Testing, repo: Ex338.Repo
  alias Ex338.Jobs
  alias Ex338.CalendarAssistant

  describe "get_autodraft_job_by/1" do
    test "starts autodraft for a championship and a fantasy_league" do
      fantasy_league = insert(:fantasy_league)
      championship = insert(:championship)

      five_mins = CalendarAssistant.mins_from_now(5)

      Oban.Testing.with_testing_mode(:manual, fn ->
        {:ok, job} =
          %{fantasy_league_id: fantasy_league.id, championship_id: championship.id}
          |> Ex338.Workers.InSeasonAutodraftWorker.new(scheduled_at: five_mins)
          |> Oban.insert()

        result =
          Jobs.get_autodraft_job_by(%{
            fantasy_league_id: fantasy_league.id,
            championship_id: championship.id
          })

        assert result.id == job.id
        assert result.scheduled_at |> DateTime.truncate(:second) == five_mins
      end)
    end
  end
end
