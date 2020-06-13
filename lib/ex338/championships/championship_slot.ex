defmodule Ex338.Championships.ChampionshipSlot do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.ChampionshipResult

  schema "championship_slots" do
    field(:slot, :integer)
    belongs_to(:roster_position, Ex338.RosterPositions.RosterPosition)
    belongs_to(:championship, Ex338.Championships.Championship)

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
    from(
      s in query,
      join: r in assoc(s, :roster_position),
      join: f in assoc(r, :fantasy_team),
      join: p in assoc(r, :fantasy_player),
      left_join: cr in ChampionshipResult,
      on: cr.fantasy_player_id == p.id and s.championship_id == cr.championship_id,
      join: c in assoc(s, :championship),
      where: f.fantasy_league_id == ^league_id,
      where: r.active_at < c.championship_at,
      where: r.released_at > c.championship_at or is_nil(r.released_at),
      order_by: [f.team_name, s.slot],
      preload: [roster_position: :fantasy_team],
      preload: [roster_position: {r, fantasy_player: {p, championship_results: cr}}],
      preload: [:championship]
    )
  end
end
