defmodule Ex338.FantasyPlayer do
  @moduledoc false

  use Ex338.Web, :model

  schema "fantasy_players" do
    field :player_name, :string
    belongs_to :sports_league, Ex338.SportsLeague
    has_many :roster_positions, Ex338.RosterPosition
    has_many :fantasy_teams, through: [:roster_positions, :fantasy_teams]
    has_many :transaction_line_items, Ex338.TransactionLineItem
    has_many :roster_transactions, through: [:transaction_line_items, 
                                             :roster_transaction]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:player_name, :sports_league_id])
    |> validate_required([:player_name, :sports_league_id])
  end
end
