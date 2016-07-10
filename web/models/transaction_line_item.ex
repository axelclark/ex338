defmodule Ex338.TransactionLineItem do
  @moduledoc false
  
  use Ex338.Web, :model

  schema "transaction_line_items" do
    field :action, :string
    belongs_to :roster_transaction, Ex338.RosterTransaction
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :fantasy_player, Ex338.FantasyPlayer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:roster_transaction_id, :action, :fantasy_team_id, 
                     :fantasy_player_id])
    |> validate_required([:roster_transaction_id, :action, :fantasy_team_id, 
                     :fantasy_player_id])
  end
end
