defmodule Ex338.FantasyLeagueChampionship do
  @moduledoc false
  use Ex338Web, :model

  schema "fantasy_league_championships" do
    belongs_to(:fantasy_league, Ex338.FantasyLeague)
    belongs_to(:championship, Ex338.Championship)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:fantasy_league_id, :championship_id])
    |> validate_required([:fantasy_league_id, :championship_id])
  end
end
