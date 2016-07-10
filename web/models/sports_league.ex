defmodule Ex338.SportsLeague do
  @moduledoc false

  use Ex338.Web, :model

  schema "sports_leagues" do
    field :league_name, :string
    field :waiver_deadline, Ecto.DateTime
    field :trade_deadline, Ecto.DateTime
    field :championship_date, Ecto.DateTime
    has_many :fantasy_players, Ex338.FantasyPlayer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:league_name, :waiver_deadline, :trade_deadline,
                     :championship_date])
    |> validate_required([:league_name, :waiver_deadline, :trade_deadline,
                          :championship_date])
  end
end
