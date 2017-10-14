defmodule Ex338.Trade do
  @moduledoc false

  use Ex338Web, :model

  @status_options ~w(Pending Approved Disapproved)

  schema "trades" do
    field :status, :string
    field :additional_terms, :string
    has_many :trade_line_items, Ex338.TradeLineItem

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(trade, params \\ %{}) do
    trade
    |> cast(params, [:status, :additional_terms])
    |> validate_required([:status])
  end

  def status_options, do: @status_options

  def by_league(query, league_id) do
    from t in query,
      join: l in assoc(t, :trade_line_items),
      join: gt in assoc(l, :gaining_team),
      join: lt in assoc(l, :losing_team),
      where: gt.fantasy_league_id == ^league_id or
        lt.fantasy_league_id == ^league_id,
      group_by: t.id
  end

  def preload_assocs(query) do
    from t in query,
      preload: [trade_line_items: [
                 gaining_team: :fantasy_league,
                 losing_team: :fantasy_league,
                 fantasy_player: :sports_league
               ]]
  end

  def newest_first(query) do
    from t in query,
      order_by: [desc: t.inserted_at]
  end
end
