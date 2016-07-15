defmodule Ex338.FantasyTeam do
  @moduledoc false

  use Ex338.Web, :model

  schema "fantasy_teams" do
    field :team_name, :string
    field :waiver_position, :integer
    belongs_to :fantasy_league, Ex338.FantasyLeague
    has_many :roster_positions, Ex338.RosterPosition
    has_many :fantasy_players, through: [:roster_positions, :fantasy_player]
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
    |> cast(params, [:team_name, :waiver_position, :fantasy_league_id])
    |> validate_required([:team_name, :waiver_position])
  end

  def by_league(query, league_id) do
    from t in query,
      where: t.fantasy_league_id == ^league_id
  end 

  def alphabetical(query) do
    from t in query, order_by: t.team_name
  end
end
