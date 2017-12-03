defmodule Ex338.TradeVote do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Ex338.TradeVote

  schema "trade_votes" do
    field :approve, :boolean, default: true
    belongs_to :trade, Ex338.Trade
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :user, Ex338.User

    timestamps()
  end

  @doc false
  def changeset(%TradeVote{} = trade_vote, attrs) do
    trade_vote
    |> cast(attrs, [:approve, :trade_id, :fantasy_team_id, :user_id])
    |> validate_required([:approve, :trade_id, :fantasy_team_id, :user_id])
    |> unique_constraint(:trade,
         name: :trade_votes_trade_id_fantasy_team_id_index,
         message: "Team has already voted"
       )
  end
end
