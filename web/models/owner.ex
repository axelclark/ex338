defmodule Ex338.Owner do
  use Ex338.Web, :model

  schema "owners" do
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :user, Ex338.User

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:fantasy_team_id, :user_id])
    |> validate_required([:fantasy_team_id, :user_id])
  end

  def by_league(query, league_id) do
    from o in query,
      join: f in assoc(o, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      order_by: [desc: f.team_name]
  end
end
