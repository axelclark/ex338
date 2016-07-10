defmodule Ex338.RosterTransaction do
  @moduledoc false
  
  use Ex338.Web, :model

  schema "roster_transactions" do
    field :category, :string
    field :additional_terms, :string
    field :roster_transaction_on, Ecto.DateTime
    has_many :transaction_line_items, Ex338.TransactionLineItem

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
end
