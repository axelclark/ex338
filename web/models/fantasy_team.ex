defmodule Ex338.FantasyTeam do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{FantasyLeague, DraftPick, Waiver, RosterPosition, Owner,
               RosterAdmin, FantasyTeam, Repo, ChampionshipResult}

  schema "fantasy_teams" do
    field :team_name, :string
    field :waiver_position, :integer
    field :dues_paid, :decimal
    field :winnings_received, :decimal
    field :commish_notes, :string
    belongs_to :fantasy_league, FantasyLeague
    has_many :roster_positions, RosterPosition
    has_many :fantasy_players, through: [:roster_positions, :fantasy_player]
    has_many :draft_picks, DraftPick
    has_many :waivers, Waiver
    has_many :owners, Owner
    has_many :users, through: [:owners, :user]

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

  def get_all_teams_for_standings(league_id) do
    league_id
    |> all_teams
    |> order_for_standings
    |> Repo.all
  end

  def get_all_teams_with_open_positions(league_id) do
    league_id
    |> all_teams
    |> alphabetical
    |> Repo.all
    |> RosterAdmin.add_open_positions_to_teams
  end

  def get_team_with_open_positions(team_id) do
    team_id
    |> get_team
    |> RosterAdmin.add_open_positions_to_team
  end

  def get_team(team_id) do
    FantasyTeam
    |> FantasyTeam.preload_active_positions
    |> preload([[owners: :user], :fantasy_league])
    |> Repo.get!(team_id)
  end

  def get_team_to_update(team_id) do
    FantasyTeam
    |> FantasyTeam.preload_active_positions
    |> preload([[owners: :user], :fantasy_league])
    |> Repo.get!(team_id)
    |> RosterAdmin.order_by_position
  end

  def get_owned_players(team_id) do
    team_id |> FantasyTeam.owned_players |> Repo.all
  end

  def update_team(fantasy_team, fantasy_team_params) do
    fantasy_team
    |> FantasyTeam.owner_changeset(fantasy_team_params)
    |> Repo.update
  end

  def all_teams(league_id) do
    FantasyTeam
    |> FantasyLeague.by_league(league_id)
    |> FantasyTeam.preload_active_positions
  end

  def alphabetical(query) do
    from t in query, order_by: t.team_name
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

  def preload_active_positions(query) do
    active_positions = RosterPosition.active_positions(RosterPosition)

    from t in query,
      preload: [roster_positions: ^active_positions]
  end

  def right_join_players_by_league(fantasy_league_id) do
    from t in FantasyTeam,
      left_join: r in RosterPosition,
      on: r.fantasy_team_id == t.id
        and t.fantasy_league_id == ^fantasy_league_id
        and r.status == "active",
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
