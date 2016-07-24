defmodule Ex338.RosterPosition do
  @moduledoc false

  use Ex338.Web, :model

  @positions ["CL", "CBB", "CFB", "CH", "KD", "LLWS", "MLB", "NBA", "NFL", 
              "NHL", "PGA", "SC", "Tennis(M)", "Tennis(W)", "Any"]

  schema "roster_positions" do
    field :position, :string
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :fantasy_player, Ex338.FantasyPlayer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:position, :fantasy_team_id, :fantasy_player_id])
    |> validate_required([:position, :fantasy_team_id])
  end

  def positions, do: @positions
end
