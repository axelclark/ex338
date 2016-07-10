defmodule Ex338.FantasyPlayer do
  @moduledoc false

  use Ex338.Web, :model

  schema "fantasy_players" do
    field :player_name, :string
    belongs_to :sports_league, Ex338.SportsLeague

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:player_name, :sports_league_id])
    |> validate_required([:player_name])
  end
end
