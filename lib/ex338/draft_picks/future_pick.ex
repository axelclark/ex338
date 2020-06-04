defmodule Ex338.DraftPicks.FuturePick do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  schema "future_picks" do
    field(:round, :integer)
    belongs_to(:original_team, Ex338.FantasyTeam, foreign_key: :original_team_id)
    belongs_to(:current_team, Ex338.FantasyTeam, foreign_key: :current_team_id)

    timestamps()
  end

  def by_league(query, fantasy_league_id) do
    from(
      p in query,
      join: t in assoc(p, :current_team),
      where: t.fantasy_league_id == ^fantasy_league_id
    )
  end

  @doc false
  def changeset(future_pick, attrs) do
    future_pick
    |> cast(attrs, [:round, :original_team_id, :current_team_id])
    |> validate_required([:round, :original_team_id, :current_team_id])
  end

  def preload_assocs(query) do
    from(
      p in query,
      preload: [:current_team, :original_team]
    )
  end

  def sort_by_round_and_team(query) do
    from(
      p in query,
      join: t in assoc(p, :current_team),
      order_by: [t.team_name, p.round]
    )
  end
end
