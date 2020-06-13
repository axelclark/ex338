defmodule Ex338.Trades.TradeVote do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Ex338.Trades.TradeVote

  schema "trade_votes" do
    field(:approve, :boolean, default: true)
    belongs_to(:trade, Ex338.Trades.Trade)
    belongs_to(:fantasy_team, Ex338.FantasyTeams.FantasyTeam)
    belongs_to(:user, Ex338.Accounts.User)

    timestamps()
  end

  def assoc_changeset(%TradeVote{} = trade_vote, attrs) do
    trade_vote
    |> cast(attrs, [:approve, :fantasy_team_id, :user_id])
    |> validate_required([:approve, :fantasy_team_id, :user_id])
    |> unique_constraint(
      :trade,
      name: :trade_votes_trade_id_fantasy_team_id_index,
      message: "Team has already voted"
    )
  end

  @doc false
  def changeset(%TradeVote{} = trade_vote, attrs) do
    trade_vote
    |> cast(attrs, [:approve, :trade_id, :fantasy_team_id, :user_id])
    |> validate_required([:approve, :trade_id, :fantasy_team_id, :user_id])
    |> unique_constraint(
      :trade,
      name: :trade_votes_trade_id_fantasy_team_id_index,
      message: "Team has already voted"
    )
  end
end
