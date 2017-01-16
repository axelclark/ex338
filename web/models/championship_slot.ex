defmodule Ex338.ChampionshipSlot do
  use Ex338.Web, :model

  schema "championship_slots" do
    field :slot, :integer
    belongs_to :roster_position, Ex338.RosterPosition
    belongs_to :championship, Ex338.Championship

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:slot, :roster_position_id, :championship_id])
    |> validate_required([:slot])
  end
end
