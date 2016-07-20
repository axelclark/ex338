defmodule Ex338.FantasyPlayer do
  @moduledoc false

  use Ex338.Web, :model

  schema "fantasy_players" do
    field :player_name, :string
    belongs_to :sports_league, Ex338.SportsLeague
    has_many :roster_positions, Ex338.RosterPosition
    has_many :fantasy_teams, through: [:roster_positions, :fantasy_team]
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

  def with_sports_and_owners(query) do
    from p in query,
      join: s in assoc(p, :sports_league),                         
      left_join: t in assoc(p, :fantasy_teams),
      select: %{player_name: p.player_name, league_name: s.league_name,
                team_name: t.team_name}
  end
end
