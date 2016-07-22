defmodule Ex338.DraftPick do
  use Ex338.Web, :model

  schema "draft_picks" do
    field :draft_position, :decimal
    field :round, :integer
    belongs_to :fantasy_league, Ex338.FantasyLeague
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :fantasy_player, Ex338.FantasyPlayer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:draft_position, :round, :fantasy_league_id, 
                     :fantasy_team_id, :fantasy_player_id])
    |> validate_required([:draft_position, :round, :fantasy_league_id])
  end
end
