defmodule Ex338.ChampionshipSlot do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{RosterPosition}

  schema "championship_slots" do
    field :slot, :integer
    belongs_to :roster_position, Ex338.RosterPosition
    belongs_to :championship, Ex338.Championship

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(slot_struct, params \\ %{}) do
    slot_struct
    |> cast(params, [:slot, :roster_position_id, :championship_id])
    |> validate_required([:slot])
  end

  def preload_assocs_by_league(query, league_id) do
    from s in query,
      join: r in assoc(s, :roster_position),
      join: f in assoc(r, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      where: r.status == "active",
      order_by: [f.team_name, s.slot],
      preload: [roster_position: [:fantasy_team, :fantasy_player]],
      preload: [:championship]
  end
end
