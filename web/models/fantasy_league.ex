defmodule Ex338.FantasyLeague do
  @moduledoc false

  use Ex338.Web, :model

  schema "fantasy_leagues" do
    field :year, :integer
    field :division, :string
    has_many :fantasy_teams, Ex338.FantasyTeam

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:year, :division])
    |> validate_required([:year, :division])
  end
end
