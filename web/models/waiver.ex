defmodule Ex338.Waiver do
  use Ex338.Web, :model

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
                     :drop_fantasy_player_id])
    |> validate_required([:fantasy_team_id])
    |> set_datetime_to_process
    |> foreign_key_constraint(:fantasy_team_id)
    |> foreign_key_constraint(:drop_fantasy_player_id)
    |> foreign_key_constraint(:add_fantasy_player_id)
  end

  def set_datetime_to_process(changeset) do
    put_change(changeset, :process_at, three_days_from_now)
  end

  def status_options, do: @status_options

  def by_league(query, league_id) do
    from w in query,
      join: f in assoc(w, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      order_by: [desc: w.inserted_at]
  end

  defp three_days_from_now do
    three_days = 86400*3
    now = Ecto.DateTime.utc
          |> Ecto.DateTime.to_erl
          |> Calendar.DateTime.from_erl!("UTC")

    now
    |> Calendar.DateTime.add!(three_days)
    |> Calendar.DateTime.to_erl
    |> Ecto.DateTime.from_erl
  end
end
