defmodule Ex338.FantasyTeam do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{RosterPosition, FantasyTeam, ChampionshipResult}

  schema "fantasy_teams" do
    field :team_name, :string
    field :waiver_position, :integer
    field :dues_paid, :decimal
    field :winnings_received, :decimal
    field :commish_notes, :string
    belongs_to :fantasy_league, Ex338.FantasyLeague
    has_many :champ_with_events_results, Ex338.ChampWithEventsResult
    has_many :draft_picks, Ex338.DraftPick
    has_many :injured_reserves, Ex338.InjuredReserve
    has_many :owners, Ex338.Owner
    has_many :users, through: [:owners, :user]
    has_many :roster_positions, Ex338.RosterPosition
    has_many :fantasy_players, through: [:roster_positions, :fantasy_player]
    has_many :waivers, Ex338.Waiver

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:team_name, :waiver_position, :fantasy_league_id,
                     :dues_paid, :winnings_received, :commish_notes])
    |> validate_required([:team_name, :waiver_position])
    |> validate_length(:team_name, max: 16)
  end

  def owner_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:team_name])
    |> validate_required([:team_name])
    |> cast_assoc(:roster_positions)
    |> validate_length(:team_name, max: 16)
  end

  def alphabetical(query) do
    from t in query, order_by: t.team_name
  end

  def by_league(query, league_id) do
    from t in query,
      where: t.fantasy_league_id == ^league_id
  end

  def find_team(query, id) do
    from f in query, where: f.id == ^id
  end

  def order_for_standings(query) do
    from t in query, order_by: t.waiver_position
  end

  def owned_players(team_id) do
    from t in FantasyTeam,
      inner_join: r in assoc(t, :roster_positions),
      inner_join: p in assoc(r, :fantasy_player),
      inner_join: s in assoc(p, :sports_league),
      where: t.id == ^team_id and r.status == "active",
      select: %{player_name: p.player_name, league_abbrev: s.abbrev, id: p.id},
      order_by: [s.abbrev, p.player_name]
  end

  def preload_active_positions_for_sport(query, sports_league_id) do
    positions =
      RosterPosition.active_by_sports_league(RosterPosition, sports_league_id)

    from t in query,
      preload: [roster_positions: ^positions]
  end

  def preload_assocs(query) do
    query
    |> FantasyTeam.preload_current_positions
    |> preload([[owners: :user], :fantasy_league])
  end

  def preload_current_positions(query) do
    current_positions = RosterPosition.current_positions(RosterPosition)

    from t in query,
      preload: [roster_positions: ^current_positions]
  end

  def right_join_players_by_league(fantasy_league_id) do
    from t in FantasyTeam,
      left_join: r in RosterPosition,
      on: r.fantasy_team_id == t.id
        and t.fantasy_league_id == ^fantasy_league_id
        and (r.status == "active" or r.status == "injured_reserve"),
      right_join: p in assoc(r, :fantasy_player),
      inner_join: s in assoc(p, :sports_league),
      left_join: cr in subquery(
        ChampionshipResult.only_overall(ChampionshipResult)
      ),
      on: cr.fantasy_player_id == p.id,
      select: %{team_name: t.team_name, player_name: p.player_name,
       league_name: s.league_name, rank: cr.rank, points: cr.points},
      order_by: [s.league_name, p.player_name]
  end

  def update_league_waiver_positions(query,
    %FantasyTeam{waiver_position: position, fantasy_league_id: league_id}) do
     from f in query,
       where: f.waiver_position > ^position,
       where: f.fantasy_league_id == ^league_id,
       update: [inc: [waiver_position: -1]]
  end
end
