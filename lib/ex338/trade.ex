defmodule Ex338.Trade do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.{TradeLineItem}

  @status_options ~w(Pending Approved Disapproved)

  schema "trades" do
    field :status, :string, default: "Pending"
    field :additional_terms, :string, default: ""
    belongs_to :submitted_by_team, Ex338.FantasyTeam
    belongs_to :submitted_by_user, Ex338.User
    has_many :trade_line_items, TradeLineItem
    has_many :trade_votes, Ex338.TradeVote

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(trade, params \\ %{}) do
    trade
    |> cast(params, [
      :status, :additional_terms, :submitted_by_team_id, :submitted_by_user_id
    ])
    |> validate_required([:status])
    |> validate_inclusion(:status, @status_options)
  end

  def new_changeset(trade, params \\ %{}) do
    trade
    |> cast(params, [
      :status, :additional_terms, :submitted_by_team_id, :submitted_by_user_id
    ])
    |> validate_required([:status])
    |> validate_inclusion(:status, @status_options)
    |> cast_assoc(:trade_line_items, required: true,
                  with: &TradeLineItem.assoc_changeset/2)
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
    preload: [
      :submitted_by_user,
      :submitted_by_team,
      trade_line_items: [
        gaining_team: :fantasy_league,
        losing_team: :fantasy_league,
        fantasy_player: :sports_league
      ]
    ]
  end

  def newest_first(query) do
    from t in query,
      order_by: [desc: t.inserted_at]
  end
end
