defmodule Ex338.TradeLineItem do
  @moduledoc false

  use Ex338.Web, :model

  @action_options ~w(sends gets)

  schema "trade_line_items" do
    belongs_to :trade, Ex338.Trade
    belongs_to :fantasy_team, Ex338.FantasyTeam
    field :action, :string
    belongs_to :fantasy_player, Ex338.FantasyPlayer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:action, :trade_id, :fantasy_team_id, :fantasy_player_id])
    |> validate_required([:action, :trade_id, :fantasy_team_id,
                          :fantasy_player_id])
  end

  def action_options, do: @action_options
end
