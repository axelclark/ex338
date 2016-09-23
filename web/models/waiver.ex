defmodule Ex338.Waiver do
  use Ex338.Web, :model

  @status_options ["Pending", "Unsuccessful", "Successful"]

  schema "waivers" do
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :add_fantasy_player, Ex338.FantasyPlayer
    belongs_to :drop_fantasy_player, Ex338.FantasyPlayer
    field :status, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:status, :fantasy_team_id, :add_fantasy_player_id,
                     :drop_fantasy_player_id])
    |> validate_required([:fantasy_team_id])
  end

  def new_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:fantasy_team_id, :add_fantasy_player_id,
                     :drop_fantasy_player_id])
    |> validate_required([:fantasy_team_id])
    |> foreign_key_constraint(:fantasy_team_id)
    |> foreign_key_constraint(:drop_fantasy_player_id)
    |> foreign_key_constraint(:add_fantasy_player_id)
  end

  def status_options, do: @status_options

  def by_league(query, league_id) do
    from w in query,
      join: f in assoc(w, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      order_by: [desc: w.inserted_at]
  end
end
