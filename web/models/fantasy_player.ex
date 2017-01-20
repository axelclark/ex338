defmodule Ex338.FantasyPlayer do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{RosterPosition, FantasyTeam, Championship, Repo, ChampionshipResult}

  schema "fantasy_players" do
    field :player_name, :string
    belongs_to :sports_league, Ex338.SportsLeague
    has_many :roster_positions, Ex338.RosterPosition
    has_many :fantasy_teams, through: [:roster_positions, :fantasy_team]
    has_many :draft_picks, Ex338.DraftPick
    has_many :waiver_adds, Ex338.Waiver, foreign_key: :add_fantasy_player_id
    has_many :waivers_drops, Ex338.Waiver, foreign_key: :drop_fantasy_player_id
    has_many :ir_adds, Ex338.InjuredReserve, foreign_key: :add_player_id
    has_many :ir_removes, Ex338.InjuredReserve, foreign_key: :remove_player_id
    has_many :ir_replacements, Ex338.InjuredReserve, foreign_key: :replacement_player_id
    has_many :championship_results, Ex338.ChampionshipResult
    has_many :championships, through: [:championship_results, :championships]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(player_struct, params \\ %{}) do
    player_struct
    |> cast(params, [:player_name, :sports_league_id])
    |> validate_required([:player_name, :sports_league_id])
  end

  def alphabetical_by_league(query) do
    from f in query,
      join: s in assoc(f, :sports_league),
      order_by: [s.league_name, f.player_name]
  end

  def names_and_ids(query) do
    from f in query, select: {f.player_name, f.id}
  end

  def get_available_players(fantasy_league_id) do
    fantasy_league_id
    |> available_players
    |> Repo.all
  end

  def get_all_players do
    __MODULE__
    |> alphabetical_by_league
    |> Repo.all
  end

  def get_next_championship(query, fantasy_player_id) do
    query = from p in query,
      inner_join: s in assoc(p, :sports_league),
      inner_join: c in subquery(
        Championship.future_championships(Championship)),
       on: c.sports_league_id == s.id,
      where: p.id == ^fantasy_player_id,
      limit: 1,
      select: c

    Repo.one(query)
  end

  def available_players(fantasy_league_id) do
    from t in FantasyTeam,
    left_join: r in RosterPosition,
    on: r.fantasy_team_id == t.id and r.status == "active" and
      t.fantasy_league_id == ^fantasy_league_id,
    right_join: p in assoc(r, :fantasy_player),
    inner_join: s in assoc(p, :sports_league),
    inner_join: c in subquery(
      Championship.all_with_overall_waivers_open(Championship)),
     on: c.sports_league_id == s.id,
    where: is_nil(r.fantasy_team_id),
    select: %{player_name: p.player_name, league_abbrev: s.abbrev, id: p.id},
    order_by: [s.abbrev, p.player_name]
  end

  def preload_overall_results(query) do
    overall_results = ChampionshipResult.only_overall(ChampionshipResult)

    from p in query,
      preload: [championship_results: ^overall_results],
      preload: [:sports_league]
  end

  def preload_positions_by_league(query, league_id) do
    positions = RosterPosition.by_league(RosterPosition, league_id)

    from f in query,
      preload: [roster_positions: ^positions]
  end
end
