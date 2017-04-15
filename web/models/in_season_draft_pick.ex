defmodule Ex338.InSeasonDraftPick do
  @moduledoc false
  use Ex338.Web, :model

  schema "in_season_draft_picks" do
    field :position, :integer
    field :next_pick, :boolean, virtual: true, default: false
    belongs_to :draft_pick_asset, Ex338.RosterPosition
    belongs_to :drafted_player, Ex338.FantasyPlayer
    belongs_to :championship, Ex338.Championship

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(pick, params \\ %{}) do
    pick
    |> cast(params, [:position, :draft_pick_asset_id, :drafted_player_id,
                     :championship_id])
    |> validate_required([:position, :draft_pick_asset_id, :championship_id])
  end

  def owner_changeset(pick, params \\ %{}) do
    pick
    |> cast(params, [:drafted_player_id])
    |> validate_required([:drafted_player_id])
  end

  def draft_order(query) do
    from d in query, order_by: d.position
  end

  def no_player_drafted(query) do
    from d in query, where: is_nil(d.drafted_player_id)
  end

  def preload_assocs(query) do
    from d in query,
      order_by: [d.position],
      preload: [draft_pick_asset: [:fantasy_player, :in_season_draft_picks,
                :championship_slots, [fantasy_team: :owners]]],
      preload: [:championship, drafted_player: :sports_league]
  end

  def preload_assocs_by_league(query, league_id) do
    from d in query,
      join: r in assoc(d, :draft_pick_asset),
      join: t in assoc(r, :fantasy_team),
      left_join: o in assoc(t, :owners),
      join: p in assoc(r, :fantasy_player),
      where: t.fantasy_league_id == ^league_id,
      order_by: [d.position],
      preload: [draft_pick_asset: {r, fantasy_player: p,
                fantasy_team: {t, owners: o}}],
      preload: [:championship, drafted_player: :sports_league]
  end

  def player_drafted(query) do
    from d in query, where: not is_nil(d.drafted_player_id)
  end

  def reverse_order(query) do
    from d in query, order_by: [desc: d.position]
  end

  def update_next_pick(draft_picks) do
    next_pick = next_pick?(draft_picks)
    update_next_pick(draft_picks, next_pick)
  end

  defp update_next_pick(draft_picks, nil) do
    draft_picks
  end

  defp update_next_pick(draft_picks, next_pick) do
    List.update_at(draft_picks, next_pick, &(%{&1|next_pick: true}))
  end

  defp next_pick?(draft_picks) do
    Enum.find_index(draft_picks, &(&1.drafted_player_id == nil))
  end
end
