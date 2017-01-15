defmodule Ex338.InjuredReserve do
  @moduledoc false

  use Ex338.Web, :model

  @status_options ["pending",
                   "successful",
                   "invalid"]

  schema "injured_reserves" do
    field :status, :string
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :add_player, Ex338.FantasyPlayer
    belongs_to :remove_player, Ex338.FantasyPlayer
    belongs_to :replacement_player, Ex338.FantasyPlayer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(ir_struct, params \\ %{}) do
    ir_struct
    |> cast(params, [:status, :fantasy_team_id, :add_player_id,
                     :remove_player_id, :replacement_player_id])
    |> validate_required([:fantasy_team_id, :status])
  end

  def status_options, do: @status_options
end
