defmodule Ex338.Jobs do
  @moduledoc false
  import Ecto.Query, warn: false

  alias Ex338.Repo

  def get_autodraft_job_by(params) do
    %{championship_id: championship_id, fantasy_league_id: fantasy_league_id} = params

    query =
      Oban.Job
      |> where([j], j.worker == "Ex338.Workers.InSeasonAutodraftWorker")
      |> where(
        [j],
        fragment("?->>'championship_id' = ?", j.args, ^"#{championship_id}")
      )
      |> where(
        [j],
        fragment("?->>'fantasy_league_id' = ?", j.args, ^"#{fantasy_league_id}")
      )

    Repo.one(query)
  end
end
