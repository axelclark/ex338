defmodule Ex338.RosterPosition do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{FantasyTeam, FantasyPlayer, RosterPosition}

  @positions ["CL", "CBB", "CFB", "CHK", "EPL", "KD", "LLWS", "MTn", "MLB",
              "NBA", "NFL", "NHL", "PGA", "WTn", "Flex1", "Flex2", "Flex3",
              "Flex4", "Flex5", "Flex6"]

  schema "roster_positions" do
    belongs_to :fantasy_team, FantasyTeam
    field :position, :string
    belongs_to :fantasy_player, FantasyPlayer

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
