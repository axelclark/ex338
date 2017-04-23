defmodule Ex338.RosterPosition do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{FantasyPlayer, Repo}

  @default_position ["Unassigned"]

  @flex_positions ["Flex1", "Flex2", "Flex3", "Flex4", "Flex5", "Flex6"]

  @positions_for_2017 ["CL", "CBB", "CFB", "CHK", "EPL", "KD", "LLWS", "MTn",
                       "MLB", "NBA", "NFL", "NHL", "PGA", "WTn"]

  @status_options ["active", "injured_reserve", "dropped", "traded", "drafted_pick"]

  schema "roster_positions" do
    belongs_to :fantasy_team, Ex338.FantasyTeam
    field :position, :string
    belongs_to :fantasy_player, Ex338.FantasyPlayer
    field :status, :string
    field :active_at, Ecto.DateTime
    field :released_at, Ecto.DateTime
    has_many :championship_slots, Ex338.ChampionshipSlot
    has_many :in_season_draft_picks, Ex338.InSeasonDraftPick, foreign_key: :draft_pick_asset_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:position, :fantasy_team_id, :fantasy_player_id, :status,
                     :released_at, :active_at])
    |> validate_required([:fantasy_team_id])
    |> unique_constraint(:position,
         name: :roster_positions_position_fantasy_team_id_index,
         message: "Already have a player in this position")
    |> check_constraint(:position, name: :position_not_null,
         message: "Position cannot be blank or remain Unassigned")
  end

  def flex_positions, do: @flex_positions

  def default_position, do: @default_position

  def status_options, do: @status_options

  def all_positions_for_2017, do: @positions_for_2017 ++ @flex_positions

  def active_positions(query) do
    players_with_results = FantasyPlayer
                           |> FantasyPlayer.preload_overall_results

    from r in query,
      where: r.status == "active",
      preload: [fantasy_player: ^players_with_results]
  end

  def active_by_sports_league(query, sports_league_id) do
    from r in query,
      join: p in assoc(r, :fantasy_player),
      where: p.sports_league_id == ^sports_league_id,
      where: r.status == "active"
  end

  def all_active(query) do
    from r in query,
      where: r.status == "active"
  end

  def all_draft_picks(query) do
    from r in query,
      join: p in assoc(r, :fantasy_player),
      where: p.draft_pick == true
  end

  def by_league(query, league_id) do
    from r in query,
      join: f in assoc(r, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      where: r.status == "active",
      preload: [:fantasy_team]
  end

  def count_positions_for_team(query, team_id) do
    query =
      from r in query,
        where: r.fantasy_team_id == ^team_id,
        where: r.status == "active"

    Repo.aggregate(query, :count, :id)
  end

  def current_positions(query) do
    players_with_results = FantasyPlayer
                           |> FantasyPlayer.preload_overall_results

    from r in query,
      where: r.status == "injured_reserve" or r.status == "active",
      preload: [fantasy_player: ^players_with_results]
  end

  def from_league(query, league_id) do
    from r in query,
      join: f in assoc(r, :fantasy_team),
      where: f.fantasy_league_id == ^league_id
  end

  def preload_assocs(query) do
    from r in query,
      preload: [:fantasy_team, :fantasy_player],
      preload: [:championship_slots, :in_season_draft_picks]
  end

  def sport_from_champ(query, championship_id) do
    from r in query,
      join: p in assoc(r, :fantasy_player),
      join: s in assoc(p, :sports_league),
      join: c in assoc(s, :championships),
      where: c.id == ^championship_id
  end

  def update_position_status(query, team_id, player_id, released_at, status) do
    from r in query,
      where: r.fantasy_team_id   == ^team_id,
      where: r.fantasy_player_id == ^player_id,
      update: [set: [released_at: ^released_at]],
      update: [set: [status:      ^status]]
  end
end
