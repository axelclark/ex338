defmodule Ex338.ChampWithEventsResult do
  @moduledoc false

  use Ex338Web, :model

  schema "champ_with_events_results" do
    field(:rank, :integer)
    field(:points, :float)
    field(:winnings, :float)
    belongs_to(:fantasy_team, Ex338.FantasyTeam)
    belongs_to(:championship, Ex338.Championship)

    timestamps()
  end

  def before_date_in_year(query, %{year: year} = datetime) do
    from(
      cr in query,
      inner_join: c in assoc(cr, :championship),
      on: cr.championship_id == c.id and c.year == ^year and c.championship_at < ^datetime
    )
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(champ_struct, params \\ %{}) do
    champ_struct
    |> cast(params, [:rank, :points, :winnings, :fantasy_team_id, :championship_id])
    |> validate_required([:rank, :points, :winnings, :fantasy_team_id, :championship_id])
  end

  def order_by_rank(query) do
    from(c in query, order_by: [asc: c.rank])
  end

  def preload_assocs(query) do
    from(c in query, preload: [:championship, :fantasy_team])
  end

  def preload_assocs_by_league(query, league_id) do
    from(
      c in query,
      inner_join: f in assoc(c, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      preload: [:championship, :fantasy_team]
    )
  end

  def preload_ordered_assocs_by_league(query, league_id) do
    query
    |> preload_assocs_by_league(league_id)
    |> order_by_rank
  end
end
