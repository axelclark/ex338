defmodule Ex338.TradeLineItem do
  @moduledoc false

  use Ex338.Web, :model

  schema "trade_line_items" do
    belongs_to :trade, Ex338.Trade
    belongs_to :losing_team, Ex338.FantasyTeam
    belongs_to :fantasy_player, Ex338.FantasyPlayer
    belongs_to :gaining_team, Ex338.FantasyTeam

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(line_item, params \\ %{}) do
    line_item
    |> cast(params, [:trade_id, :fantasy_player_id, :losing_team_id,
                     :gaining_team_id])
    |> validate_required([:trade_id, :fantasy_player_id,
                          :losing_team_id, :gaining_team_id])
  end
end
