defmodule Ex338.FantasyTeam do
  use Ex338.Web, :model

  schema "fantasy_teams" do
    field :team_name, :string
    field :waiver_position, :integer
    belongs_to :fantasy_league, Ex338.FantasyLeague

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:team_name, :waiver_position, :fantasy_league_id])
    |> validate_required([:team_name, :waiver_position])
  end
end
