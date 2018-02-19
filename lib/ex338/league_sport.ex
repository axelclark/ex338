defmodule Ex338.LeagueSport do
  @moduledoc false
  use Ex338Web, :model

  schema "league_sports" do
    belongs_to(:fantasy_league, Ex338.FantasyLeague)
    belongs_to(:sports_league, Ex338.SportsLeague)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(league_sport, params \\ %{}) do
    league_sport
    |> cast(params, [:fantasy_league_id, :sports_league_id])
    |> validate_required([:fantasy_league_id, :sports_league_id])
  end
end
