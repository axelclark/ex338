defmodule Ex338.RosterPositions.RosterPosition do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.Repo

  @default_position ["Unassigned"]

  @all_flex_positions ["Flex1", "Flex2", "Flex3", "Flex4", "Flex5", "Flex6"]

  @status_options ["active", "injured_reserve", "dropped", "traded", "drafted_pick"]

  schema "roster_positions" do
    belongs_to(:fantasy_team, Ex338.FantasyTeam)
    field(:position, :string)
    field(:acq_method, :string, default: "unknown")
    belongs_to(:fantasy_player, Ex338.FantasyPlayers.FantasyPlayer)
    field(:status, :string)
    field(:active_at, :utc_datetime)
    field(:released_at, :utc_datetime)
    has_many(:championship_slots, Ex338.ChampionshipSlot)
    has_many(:in_season_draft_picks, Ex338.InSeasonDraftPick, foreign_key: :draft_pick_asset_id)

    timestamps()
  end

  def default_position, do: @default_position

  def all_flex_positions(), do: @all_flex_positions

  def flex_positions(num_positions), do: Enum.map(1..num_positions, &"Flex#{&1}")

  def status_options, do: @status_options

  def active_by_sports_league(query, sports_league_id) do
    query
    |> all_active()
    |> by_sports_league(sports_league_id)
  end

  def all_active(query) do
    from(r in query, where: r.status == "active")
  end

  def all_draft_picks(query) do
    from(
      r in query,
      join: p in assoc(r, :fantasy_player),
      where: p.draft_pick == true
    )
  end

  def all_owned(query) do
    from(r in query, where: r.status == "injured_reserve" or r.status == "active")
  end

  def all_owned_from_league(query, fantasy_league_id) do
    query
    |> all_owned()
    |> from_league(fantasy_league_id)
  end

  def by_league(query, league_id) do
    from(
      r in query,
      join: f in assoc(r, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      where: r.status == "active",
      preload: [:fantasy_team]
    )
  end

  def by_sports_league(query, sports_league_id) do
    from(
      r in query,
      join: p in assoc(r, :fantasy_player),
      where: p.sports_league_id == ^sports_league_id
    )
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :active_at,
      :acq_method,
      :fantasy_team_id,
      :fantasy_player_id,
      :position,
      :released_at,
      :status
    ])
    |> validate_required([:fantasy_team_id])
    |> validate_inclusion(:status, @status_options)
    |> unique_constraint(
      :position,
      name: :roster_positions_position_fantasy_team_id_index,
      message: "Already have a player in this position"
    )
    |> check_constraint(
      :position,
      name: :position_not_null,
      message: "Position cannot be blank or remain Unassigned"
    )
  end

  def count_positions_for_team(query, team_id) do
    query =
      from(
        r in query,
        where: r.fantasy_team_id == ^team_id,
        where: r.status == "active"
      )

    Repo.aggregate(query, :count, :id)
  end

  def from_league(query, league_id) do
    from(
      r in query,
      join: f in assoc(r, :fantasy_team),
      where: f.fantasy_league_id == ^league_id
    )
  end

  def order_by_id(query) do
    from(r in query, order_by: r.id)
  end

  def preload_assocs(query) do
    from(
      r in query,
      preload: [:fantasy_team, :fantasy_player],
      preload: [:championship_slots, :in_season_draft_picks]
    )
  end

  def sport_from_champ(query, championship_id) do
    from(
      r in query,
      join: p in assoc(r, :fantasy_player),
      join: s in assoc(p, :sports_league),
      join: c in assoc(s, :championships),
      where: c.id == ^championship_id
    )
  end

  def update_position_status(query, team_id, player_id, released_at, status) do
    from(
      r in query,
      where: r.fantasy_team_id == ^team_id,
      where: r.fantasy_player_id == ^player_id,
      update: [set: [released_at: ^released_at]],
      update: [set: [status: ^status]]
    )
  end
end
