defmodule Ex338.FantasyPlayers.FantasyPlayer do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Ex338.{
    Championships.Championship,
    Championships.ChampionshipResult,
    FantasyPlayers.SportsLeague,
    RosterPositions.RosterPosition
  }

  schema "fantasy_players" do
    field(:player_name, :string)
    field(:draft_pick, :boolean)
    field(:available_starting_at, :utc_datetime)
    field(:archived_at, :utc_datetime)
    belongs_to(:sports_league, Ex338.FantasyPlayers.SportsLeague)
    has_many(:roster_positions, Ex338.RosterPositions.RosterPosition)
    has_many(:fantasy_teams, through: [:roster_positions, :fantasy_team])
    has_many(:draft_picks, Ex338.DraftPicks.DraftPick)

    has_many(:in_season_draft_picks, Ex338.InSeasonDraftPicks.InSeasonDraftPick,
      foreign_key: :drafted_player_id
    )

    has_many(:waiver_adds, Ex338.Waivers.Waiver, foreign_key: :add_fantasy_player_id)
    has_many(:waivers_drops, Ex338.Waivers.Waiver, foreign_key: :drop_fantasy_player_id)
    has_many(:ir_adds, Ex338.InjuredReserves.InjuredReserve, foreign_key: :add_player_id)
    has_many(:ir_removes, Ex338.InjuredReserves.InjuredReserve, foreign_key: :remove_player_id)

    has_many(:ir_replacements, Ex338.InjuredReserves.InjuredReserve,
      foreign_key: :replacement_player_id
    )

    has_many(:championship_results, Ex338.Championships.ChampionshipResult)
    has_many(:championships, through: [:championship_results, :championships])
    has_many(:draft_queues, Ex338.DraftQueues.DraftQueue)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(player_struct, params \\ %{}) do
    player_struct
    |> cast(params, [
      :player_name,
      :draft_pick,
      :sports_league_id,
      :available_starting_at,
      :archived_at
    ])
    |> validate_required([:player_name, :sports_league_id])
  end

  def active_players(query, fantasy_league_id) do
    query
    |> by_league(fantasy_league_id)
    |> where(
      [p, s, ls, l],
      p.archived_at >= l.championships_start_at or is_nil(p.archived_at)
    )
    |> where(
      [p, s, ls, l],
      p.available_starting_at <=
        l.championships_end_at
    )
  end

  def alphabetical_by_league(query) do
    from(
      f in query,
      join: s in assoc(f, :sports_league),
      order_by: [s.league_name, f.player_name]
    )
  end

  def available_players(query, fantasy_league_id) do
    query
    |> active_players(fantasy_league_id)
    |> unowned_players(fantasy_league_id)
    |> with_waivers_open(fantasy_league_id)
    |> preload_sport()
    |> order_by_sport_abbrev()
    |> order_by_name()
  end

  def avail_players_for_sport(query, fantasy_league_id, sport_id) do
    query
    |> active_players(fantasy_league_id)
    |> unowned_players(fantasy_league_id)
    |> not_draft_pick()
    |> by_sport(sport_id)
    |> preload_sport()
    |> order_by_name()
  end

  def by_league(query, fantasy_league_id) do
    from(
      p in query,
      inner_join: s in assoc(p, :sports_league),
      inner_join: ls in assoc(s, :league_sports),
      inner_join: l in assoc(ls, :fantasy_league),
      on: ls.sports_league_id == s.id and ls.fantasy_league_id == ^fantasy_league_id
    )
  end

  def by_sport(query, sport_id) do
    from(
      p in query,
      join: s in assoc(p, :sports_league),
      where: p.sports_league_id == ^sport_id
    )
  end

  def is_draft_pick(query) do
    from(p in query, where: p.draft_pick == true)
  end

  def not_draft_pick(query) do
    from(p in query, where: p.draft_pick == false)
  end

  def order_by_name(query) do
    from(p in query, order_by: p.player_name)
  end

  def order_by_sport_abbrev(query) do
    from(
      p in query,
      inner_join: s in assoc(p, :sports_league),
      order_by: s.abbrev
    )
  end

  def order_by_sport_name(query) do
    from(
      p in query,
      inner_join: s in assoc(p, :sports_league),
      order_by: s.league_name
    )
  end

  def preload_sport(query) do
    from(p in query, preload: :sports_league)
  end

  def unowned_players(query, fantasy_league_id) do
    from(
      p in query,
      left_join:
        r in subquery(RosterPosition.all_owned_from_league(RosterPosition, fantasy_league_id)),
      on: r.fantasy_player_id == p.id,
      where: is_nil(r.id)
    )
  end

  def with_waivers_open(query, fantasy_league_id) do
    from(
      p in query,
      inner_join: s in assoc(p, :sports_league),
      inner_join:
        c in subquery(Championship.all_with_overall_waivers_open(Championship, fantasy_league_id)),
      on: c.sports_league_id == s.id
    )
  end

  def with_teams_for_league(query, fantasy_league) do
    query =
      query
      |> active_players(fantasy_league.id)
      |> order_by_sport_name()
      |> order_by_name()

    sports = SportsLeague.preload_league_overall_championships(SportsLeague, fantasy_league.id)

    positions =
      RosterPosition
      |> RosterPosition.all_owned_from_league(fantasy_league.id)
      |> RosterPosition.preload_assocs()

    %{
      championships_start_at: start_datetime,
      championships_end_at: end_datetime
    } = fantasy_league

    results =
      ChampionshipResult.overall_from_range(ChampionshipResult, start_datetime, end_datetime)

    from(p in query,
      preload: [
        sports_league: ^sports,
        roster_positions: ^positions,
        championship_results: ^results
      ]
    )
  end
end
