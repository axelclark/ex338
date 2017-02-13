defmodule Ex338.ChampWithEventsResult do
  @moduledoc false

  use Ex338.Web, :model

  schema "champ_with_events_results" do
    field :rank, :integer
    field :points, :decimal
    field :winnings, :decimal
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :championship, Ex338.Championship

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(champ_struct, params \\ %{}) do
    champ_struct
    |> cast(params, [:rank, :points, :winnings, :fantasy_team_id,
                     :championship_id])
    |> validate_required([:rank, :points, :winnings, :fantasy_team_id,
                          :championship_id])
  end
end
