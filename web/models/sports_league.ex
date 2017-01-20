defmodule Ex338.SportsLeague do
  @moduledoc false

  use Ex338.Web, :model

  schema "sports_leagues" do
    field :league_name, :string
    field :abbrev, :string
    field :waiver_deadline, Ecto.DateTime
    field :trade_deadline, Ecto.DateTime
    field :championship_date, Ecto.DateTime
    has_many :fantasy_players, Ex338.FantasyPlayer
    has_many :championships, Ex338.Championship

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:league_name, :abbrev, :waiver_deadline, :trade_deadline,
                     :championship_date])
    |> validate_required([:league_name, :abbrev, :waiver_deadline,
                          :trade_deadline, :championship_date])
  end

  def alphabetical(query) do
    from s in query, order_by: s.league_name
  end
end
