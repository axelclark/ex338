defmodule Ex338.DraftPicks.FuturePick do
  use Ecto.Schema
  import Ecto.Changeset

  schema "future_picks" do
    field(:round, :integer)
    belongs_to(:original_team, Ex338.FantasyTeam, foreign_key: :original_team_id)
    belongs_to(:current_team, Ex338.FantasyTeam, foreign_key: :current_team_id)

    timestamps()
  end

  @doc false
  def changeset(future_pick, attrs) do
    future_pick
    |> cast(attrs, [:round, :original_team_id, :current_team_id])
    |> validate_required([:round, :original_team_id, :current_team_id])
  end
end
