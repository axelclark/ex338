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
end
