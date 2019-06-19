defmodule Ex338.ChampionshipResult do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.{FantasyPlayer, RosterPosition, FantasyTeam}

  schema "championship_results" do
    belongs_to(:championship, Ex338.Championship)
    belongs_to(:fantasy_player, FantasyPlayer)
    field(:rank, :integer)
    field(:points, :integer)

    timestamps()
  end

  def before_date_in_year(query, %{year: year} = datetime) do
    from(
      cr in query,
      inner_join: c in assoc(cr, :championship),
      on: cr.championship_id == c.id and c.year == ^year and c.championship_at < ^datetime
    )
  end

  def by_year(query, year) do
    from(
      cr in query,
      inner_join: c in assoc(cr, :championship),
      on: cr.championship_id == c.id and c.year == ^year
    )
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(result_struct, params \\ %{}) do
    result_struct
    |> cast(params, [:championship_id, :fantasy_player_id, :rank, :points])
    |> validate_required([:championship_id, :fantasy_player_id, :rank, :points])
  end

  def only_overall(query) do
    from(
      cr in query,
      inner_join: c in assoc(cr, :championship),
      on: cr.championship_id == c.id and c.category == "overall"
    )
  end

  def order_by_points_rank(query) do
    from(c in query, order_by: [desc: c.points, asc: c.rank])
  end

  def overall_by_year(query, year) do
    query
    |> only_overall
    |> by_year(year)
  end

  def overall_before_date_in_year(query, datetime) do
    query
    |> only_overall
    |> before_date_in_year(datetime)
  end

  def preload_assocs_by_league(query, league_id) do
    from(
      cr in query,
      join: c in assoc(cr, :championship),
      join: p in assoc(cr, :fantasy_player),
      left_join: r in RosterPosition,
      on:
        r.fantasy_player_id == p.id and r.active_at < c.championship_at and
          (r.released_at > c.championship_at or is_nil(r.released_at)),
      left_join: f in FantasyTeam,
      on: f.id == r.fantasy_team_id,
      where: f.fantasy_league_id == ^league_id or is_nil(f.fantasy_league_id),
      order_by: [desc: cr.points, asc: cr.rank],
      preload: [:championship],
      preload: [fantasy_player: {p, roster_positions: {r, fantasy_team: f}}]
    )
  end

  def preload_ordered_assocs_by_league(query, league_id) do
    query
    |> preload_assocs_by_league(league_id)
    |> order_by_points_rank
  end
end
