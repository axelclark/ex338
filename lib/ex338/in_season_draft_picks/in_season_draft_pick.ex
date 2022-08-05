defmodule Ex338.InSeasonDraftPicks.InSeasonDraftPick do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Ex338.InSeasonDraftPicks

  schema "in_season_draft_picks" do
    field(:position, :integer)
    field(:drafted_at, :utc_datetime)
    field(:available_to_pick?, :boolean, virtual: true, default: false)
    field(:pick_due_at, :utc_datetime, virtual: true)
    field(:over_time?, :boolean, virtual: true, default: false)
    belongs_to(:fantasy_league, Ex338.FantasyLeagues.FantasyLeague)
    belongs_to(:draft_pick_asset, Ex338.RosterPositions.RosterPosition)
    belongs_to(:drafted_player, Ex338.FantasyPlayers.FantasyPlayer)
    belongs_to(:championship, Ex338.Championships.Championship)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(pick, params \\ %{}) do
    pick
    |> cast(params, [
      :position,
      :draft_pick_asset_id,
      :drafted_player_id,
      :drafted_at,
      :championship_id,
      :fantasy_league_id
    ])
    |> validate_required([:position, :draft_pick_asset_id, :championship_id, :fantasy_league_id])
    |> unique_constraint(:drafted_player_id,
      name: :in_season_draft_picks_fantasy_league_id_drafted_player_id_index,
      message: "Player already drafted in the league"
    )
  end

  def by_sport(query, sport_id) do
    from(
      d in query,
      join: c in assoc(d, :championship),
      where: c.sports_league_id == ^sport_id
    )
  end

  def draft_order(query) do
    from(d in query, order_by: d.position)
  end

  def no_player_drafted(query) do
    from(d in query, where: is_nil(d.drafted_player_id))
  end

  def owner_changeset(pick, params \\ %{}) do
    pick
    |> cast(params, [:drafted_player_id])
    |> validate_required([:drafted_player_id])
    |> validate_is_available_for_pick()
    |> add_drafted_at()
    |> unique_constraint(:drafted_player_id,
      name: :in_season_draft_picks_fantasy_league_id_drafted_player_id_index,
      message: "Player already drafted in the league"
    )
  end

  def preload_assocs(query) do
    from(
      d in query,
      order_by: [d.position],
      preload: [
        draft_pick_asset: [
          :championship_slots,
          :in_season_draft_picks,
          [fantasy_player: :sports_league],
          [fantasy_team: :owners]
        ]
      ],
      preload: [:championship, drafted_player: :sports_league]
    )
  end

  def preload_assocs_by_league(query, league_id) do
    from(
      d in query,
      join: r in assoc(d, :draft_pick_asset),
      join: t in assoc(r, :fantasy_team),
      left_join: o in assoc(t, :owners),
      join: p in assoc(r, :fantasy_player),
      join: s in assoc(p, :sports_league),
      where: t.fantasy_league_id == ^league_id,
      order_by: [d.position],
      preload: [
        draft_pick_asset: {r, fantasy_player: {p, sports_league: s}, fantasy_team: {t, owners: o}}
      ],
      preload: [:championship, drafted_player: :sports_league]
    )
  end

  def player_drafted(query) do
    from(d in query, where: not is_nil(d.drafted_player_id))
  end

  def reverse_order(query) do
    from(d in query, order_by: [desc: d.position])
  end

  def update_next_pick(draft_picks) do
    next_pick = next_pick?(draft_picks)
    update_next_pick(draft_picks, next_pick)
  end

  ## Helpers

  ## owner_changeset

  defp validate_is_available_for_pick(pick_changeset) do
    %{data: pick} = pick_changeset

    league_id = pick.draft_pick_asset.fantasy_team.fantasy_league_id
    sport_id = pick.championship.sports_league_id

    pick =
      league_id
      |> InSeasonDraftPicks.by_league_and_sport(sport_id)
      |> InSeasonDraftPicks.Clock.update_in_season_draft_picks(pick.championship)
      |> Enum.find(&(&1.id == pick.id))

    if pick.available_to_pick? do
      pick_changeset
    else
      add_error(pick_changeset, :drafted_player_id, "You don't have the next pick")
    end
  end

  defp add_drafted_at(changeset) do
    now = DateTime.truncate(DateTime.utc_now(), :second)
    put_change(changeset, :drafted_at, now)
  end

  ## update_next_pick

  defp update_next_pick(draft_picks, nil) do
    draft_picks
  end

  defp update_next_pick(draft_picks, next_pick) do
    List.update_at(draft_picks, next_pick, &%{&1 | available_to_pick?: true})
  end

  defp next_pick?(draft_picks) do
    Enum.find_index(draft_picks, &(&1.drafted_player_id == nil))
  end
end
