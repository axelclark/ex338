defmodule Ex338.RosterTransaction do
  @moduledoc false

  use Ex338.Web, :model

  @categories ["Waiver Claim", "Trade"]

  schema "roster_transactions" do
    field :category, :string
    field :roster_transaction_on, Ecto.DateTime
    field :additional_terms, :string
    has_many :transaction_line_items, Ex338.TransactionLineItem
    has_many :fantasy_teams, through: [:transaction_line_items, :fantasy_team]
    has_many :fantasy_players, through: [:transaction_line_items,
                                         :fantasy_player]

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:category, :additional_terms, :roster_transaction_on])
    |> validate_required([:category, :roster_transaction_on])
  end

  def categories, do: @categories

  def by_league(query, league_id) do
    from r in query,
      join: t in assoc(r, :transaction_line_items),
      join: f in assoc(t, :fantasy_team),
      distinct: r.id,
      where: f.fantasy_league_id == ^league_id,
      order_by: [desc: r.roster_transaction_on]
  end
end
