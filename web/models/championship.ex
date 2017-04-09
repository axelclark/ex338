defmodule Ex338.Championship do
  @moduledoc false
  use Ex338.Web, :model

  alias Ex338.{ChampionshipResult, ChampionshipSlot, ChampWithEventsResult,
               InSeasonDraftPick}

  @categories ["overall", "event"]

  schema "championships" do
    field :title, :string
    field :category, :string
    field :waiver_deadline_at, Ecto.DateTime
    field :trade_deadline_at, Ecto.DateTime
    field :championship_at, Ecto.DateTime
    field :in_season_draft, :boolean
    belongs_to :sports_league, Ex338.SportsLeague
    belongs_to :overall, Ex338.Championship
    has_many :events, Ex338.Championship, foreign_key: :overall_id
    has_many :champ_with_events_results, Ex338.ChampWithEventsResult
    has_many :championship_results, Ex338.ChampionshipResult
    has_many :championship_slots, Ex338.ChampionshipSlot
    has_many :fantasy_players, through: [:championship_results, :fantasy_player]
    has_many :in_season_draft_picks, Ex338.InSeasonDraftPick

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(championship_struct, params \\ %{}) do
    championship_struct
    |> cast(params, [:title, :category, :waiver_deadline_at, :trade_deadline_at,
                     :championship_at, :sports_league_id, :overall_id,
                     :in_season_draft])
    |> validate_required([:title, :category, :waiver_deadline_at,
                          :trade_deadline_at, :championship_at,
                          :sports_league_id])
  end

  def categories, do: @categories

  def all_with_overall_waivers_open(query) do
    from c in query,
      where: c.waiver_deadline_at > ago(0, "second"),
      where: c.category == "overall"
  end

  def earliest_first(query) do
    from c in query,
      order_by: [asc: :championship_at, asc: :category]
  end

  def future_championships(query) do
    from c in query,
      where: c.championship_at > ago(0, "second"),
      order_by: c.championship_at
  end

  def overall_championships(query) do
    from c in query,
      where: c.category == "overall"
  end

  def preload_assocs(query) do
    results =
      ChampionshipResult.preload_assocs_and_order_results(ChampionshipResult)

    from c in query,
     preload: [:sports_league, championship_results: ^results]
  end

  def preload_assocs_by_league(query, league_id) do
    champ_with_event_results =
      ChampWithEventsResult.preload_ordered_assocs_by_league(
        ChampWithEventsResult, league_id)

    results =
      ChampionshipResult.preload_ordered_assocs_by_league(
        ChampionshipResult, league_id)

    slots =
      ChampionshipSlot.preload_assocs_by_league(ChampionshipSlot, league_id)

    in_season_draft_picks =
      InSeasonDraftPick.preload_assocs_by_league(InSeasonDraftPick, league_id)

    from c in query,
     preload: [
       :sports_league,
       in_season_draft_picks: ^in_season_draft_picks,
       champ_with_events_results: ^champ_with_event_results,
       championship_results: ^results,
       championship_slots: ^slots,
     ]
  end

  def sum_slot_points(query, overall_id, league_id) do
    from c in query,
      join: s in assoc(c, :championship_slots),
      join: r in assoc(s, :roster_position),
      join: f in assoc(r, :fantasy_team),
      join: p in assoc(r, :fantasy_player),
      left_join: cr in ChampionshipResult, on: cr.fantasy_player_id == p.id and
        s.championship_id == cr.championship_id,
      where: c.overall_id == ^overall_id,
      where: f.fantasy_league_id == ^league_id,
      where: r.active_at < c.championship_at,
      where: (r.released_at > c.championship_at or is_nil(r.released_at)),
      order_by: [f.team_name, s.slot],
      group_by: [f.team_name, s.slot],
      select: %{slot: s.slot, team_name: f.team_name, points: sum(cr.points)}
  end
end
