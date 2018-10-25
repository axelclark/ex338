defmodule Ex338.HistoricalWinning do
  @moduledoc false

  use Ex338Web, :model

  schema "historical_winnings" do
    field(:team, :string)
    field(:amount, :integer)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(record, params \\ %{}) do
    record
    |> cast(params, [:team, :amount])
    |> validate_required([:team, :amount])
  end

  def order_by_amount(query) do
    from(t in query, order_by: [desc: t.amount])
  end
end
