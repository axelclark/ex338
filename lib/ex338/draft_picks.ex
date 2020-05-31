defmodule Ex338.DraftPicks do
  @moduledoc """
  The DraftPicks context.
  """

  import Ecto.Query, warn: false
  alias Ex338.Repo

  alias Ex338.DraftPicks.FuturePick

  def change_future_pick(%FuturePick{} = future_pick, attrs \\ %{}) do
    FuturePick.changeset(future_pick, attrs)
  end

  def create_future_pick(attrs \\ %{}) do
    %FuturePick{}
    |> FuturePick.changeset(attrs)
    |> Repo.insert()
  end

  def create_future_picks(teams, rounds) do
    for round <- 1..rounds, team <- teams do
      attrs = %{round: round, original_team_id: team.id, current_team_id: team.id}
      {:ok, pick} = create_future_pick(attrs)
      pick
    end
  end

  def get_future_pick!(id), do: Repo.get!(FuturePick, id)

  def update_future_pick(%FuturePick{} = future_pick, attrs) do
    future_pick
    |> FuturePick.changeset(attrs)
    |> Repo.update()
  end
end
