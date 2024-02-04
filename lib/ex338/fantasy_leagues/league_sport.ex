defmodule Ex338.FantasyLeagues.LeagueSport do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "league_sports" do
    belongs_to(:fantasy_league, Ex338.FantasyLeagues.FantasyLeague)
    belongs_to(:sports_league, Ex338.FantasyPlayers.SportsLeague)

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
