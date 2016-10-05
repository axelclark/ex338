defmodule Ex338.Waiver do
  use Ex338.Web, :model

  alias Ex338.{Waiver}

  @status_options ["pending",
                   "successful",
                   "unsuccessful",
                   "invalid"]

  schema "waivers" do
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :add_fantasy_player, Ex338.FantasyPlayer
    belongs_to :drop_fantasy_player, Ex338.FantasyPlayer
    field :status, :string
    field :process_at, Ecto.DateTime

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

  def new_changeset(waiver_struct, params \\ %{}) do
    waiver_struct
    |> cast(params, [:fantasy_team_id, :add_fantasy_player_id,
                     :drop_fantasy_player_id, :process_at])
    |> validate_required([:fantasy_team_id])
    |> validate_add_or_drop
    |> foreign_key_constraint(:fantasy_team_id)
    |> foreign_key_constraint(:drop_fantasy_player_id)
    |> foreign_key_constraint(:add_fantasy_player_id)
  end

  def status_options, do: @status_options

  def by_league(query, league_id) do
    from w in query,
      join: f in assoc(w, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      order_by: [asc: w.process_at, asc: f.waiver_position]
  end

  def pending_waivers_for_player(add_player_id, league_id) do
    from w in by_league(Waiver, league_id),
      where: w.status == "pending" and
             w.add_fantasy_player_id == ^add_player_id,
      limit: 1
  end

  defp validate_add_or_drop(waiver_changeset) do
    add  = fetch_change(waiver_changeset, :add_fantasy_player_id)
    drop = fetch_change(waiver_changeset, :drop_fantasy_player_id)

   validate_add_or_drop(waiver_changeset, add, drop)
  end

  defp validate_add_or_drop(waiver_changeset, :error, :error) do
    add_error(waiver_changeset, :empty, "Must submit an add or a drop")
  end

  defp validate_add_or_drop(waiver_changeset, _, _), do: waiver_changeset
end
