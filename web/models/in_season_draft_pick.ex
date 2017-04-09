defmodule Ex338.InSeasonDraftPick do
  @moduledoc false
  use Ex338.Web, :model

  schema "in_season_draft_picks" do
    field :position, :integer
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

  def preload_assocs_by_league(query, league_id) do
    from d in query,
      join: r in assoc(d, :draft_pick_asset),
      join: t in assoc(r, :fantasy_team),
      join: p in assoc(r, :fantasy_player),
      where: t.fantasy_league_id == ^league_id,
      order_by: [d.position],
      preload: [draft_pick_asset: {r, fantasy_player: p, fantasy_team: t}],
      preload: [:championship, drafted_player: :sports_league]
  end

  def preload_assocs(query) do
    from d in query,
      order_by: [d.position],
      preload: [draft_pick_asset: [:fantasy_player, :fantasy_team]],
      preload: [:championship, drafted_player: :sports_league]
  end
end
