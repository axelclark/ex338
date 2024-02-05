defmodule Ex338.Championships.Championship do
  @moduledoc false
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Ex338.Championships.ChampionshipResult
  alias Ex338.Championships.ChampionshipSlot
  alias Ex338.Championships.ChampWithEventsResult
  alias Ex338.InSeasonDraftPicks.InSeasonDraftPick

  @categories ["overall", "event"]

  schema "championships" do
    field(:title, :string)
    field(:category, :string)
    field(:waiver_deadline_at, :utc_datetime)
    field(:trade_deadline_at, :utc_datetime)
    field(:championship_at, :utc_datetime)
    field(:waivers_closed?, :boolean, virtual: true)
    field(:trades_closed?, :boolean, virtual: true)
    field(:season_ended?, :boolean, virtual: true)
    field(:year, :integer)
    field(:in_season_draft, :boolean)
    field(:max_draft_mins, :integer, default: 5)
    field(:draft_starts_at, :utc_datetime)
    belongs_to(:sports_league, Ex338.FantasyPlayers.SportsLeague)
    belongs_to(:overall, Ex338.Championships.Championship)
    has_many(:events, Ex338.Championships.Championship, foreign_key: :overall_id)
    has_many(:champ_with_events_results, Ex338.Championships.ChampWithEventsResult)
    has_many(:championship_results, Ex338.Championships.ChampionshipResult)
    has_many(:championship_slots, Ex338.Championships.ChampionshipSlot)
    has_many(:fantasy_players, through: [:championship_results, :fantasy_player])
    has_many(:in_season_draft_picks, Ex338.InSeasonDraftPicks.InSeasonDraftPick)

    timestamps()
  end

  def add_deadline_statuses(championship) do
    %{
      championship_at: championship_at,
      waiver_deadline_at: waiver_deadline_at,
      trade_deadline_at: trade_deadline_at
    } = championship

    championship
    |> Map.replace!(:season_ended?, before_today?(championship_at))
    |> Map.replace!(:waivers_closed?, before_today?(waiver_deadline_at))
    |> Map.replace!(:trades_closed?, before_today?(trade_deadline_at))
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(championship_struct, params \\ %{}) do
    championship_struct
    |> cast(params, [
      :title,
      :category,
      :waiver_deadline_at,
      :trade_deadline_at,
      :championship_at,
      :sports_league_id,
      :overall_id,
      :in_season_draft,
      :max_draft_mins,
      :draft_starts_at,
      :year
    ])
    |> validate_required([
      :title,
      :category,
      :waiver_deadline_at,
      :trade_deadline_at,
      :championship_at,
      :sports_league_id,
      :year
    ])
    |> validate_inclusion(:category, @categories)
  end

  def categories, do: @categories

  def all_with_overall_waivers_open(query, fantasy_league_id) do
    query
    |> all_with_overall_waivers_open()
    |> all_for_league(fantasy_league_id)
  end

  def all_overall_before_championship(query, fantasy_league_id) do
    query
    |> before_championship()
    |> overall_championships()
    |> all_for_league(fantasy_league_id)
  end

  def all_with_overall_waivers_open(query) do
    from(
      c in query,
      where: c.waiver_deadline_at > ago(0, "second"),
      where: c.category == "overall"
    )
  end

  def all_for_league(query, fantasy_league_id) do
    from(
      c in query,
      join: s in assoc(c, :sports_league),
      join: ls in assoc(s, :league_sports),
      join: f in assoc(ls, :fantasy_league),
      where: f.id == ^fantasy_league_id,
      where: c.championship_at >= f.championships_start_at,
      where: c.championship_at <= f.championships_end_at
    )
  end

  def before_championship(query) do
    from(
      c in query,
      where: c.championship_at > ago(0, "second")
    )
  end

  def earliest_first(query) do
    from(c in query, order_by: [asc: :championship_at, asc: :category])
  end

  def future_championships(query, fantasy_league_id) do
    query
    |> all_for_league(fantasy_league_id)
    |> future_championships()
  end

  def future_championships(query) do
    from(
      c in query,
      where: c.championship_at > ago(0, "second"),
      order_by: c.championship_at
    )
  end

  def overall_championships(query) do
    from(c in query, where: c.category == "overall")
  end

  def preload_assocs_by_league(query, league_id) do
    champ_with_event_results =
      ChampWithEventsResult.preload_ordered_assocs_by_league(ChampWithEventsResult, league_id)

    results = ChampionshipResult.preload_ordered_assocs_by_league(ChampionshipResult, league_id)

    slots = ChampionshipSlot.preload_assocs_by_league(ChampionshipSlot, league_id)

    in_season_draft_picks =
      InSeasonDraftPick.preload_assocs_by_league(InSeasonDraftPick, league_id)

    from(
      c in query,
      preload: [
        :sports_league,
        in_season_draft_picks: ^in_season_draft_picks,
        champ_with_events_results: ^champ_with_event_results,
        championship_results: ^results,
        championship_slots: ^slots
      ]
    )
  end

  def sum_slot_points(query, overall_id, league_id) do
    from(
      c in query,
      join: s in assoc(c, :championship_slots),
      join: r in assoc(s, :roster_position),
      join: f in assoc(r, :fantasy_team),
      join: p in assoc(r, :fantasy_player),
      left_join: cr in ChampionshipResult,
      on: cr.fantasy_player_id == p.id and s.championship_id == cr.championship_id,
      where: c.overall_id == ^overall_id,
      where: f.fantasy_league_id == ^league_id,
      where: r.active_at < c.championship_at,
      where: r.released_at > c.championship_at or is_nil(r.released_at),
      order_by: [f.team_name, s.slot],
      group_by: [f.team_name, s.slot],
      select: %{slot: s.slot, team_name: f.team_name, points: sum(cr.points)}
    )
  end

  ## Helpers

  ## add_deadline_statuses

  defp before_today?(championship_date) do
    now = DateTime.utc_now()
    result = DateTime.compare(championship_date, now)

    did_deadline_pass?(result)
  end

  defp did_deadline_pass?(:gt), do: false
  defp did_deadline_pass?(:eq), do: false
  defp did_deadline_pass?(:lt), do: true
end
