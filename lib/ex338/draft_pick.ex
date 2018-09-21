defmodule Ex338.DraftPick do
  @moduledoc false

  use Ex338Web, :model

  schema "draft_picks" do
    field(:draft_position, :float, scale: 3)
    field(:seconds_on_the_clock, :integer, virtual: true)
    belongs_to(:fantasy_league, Ex338.FantasyLeague)
    belongs_to(:fantasy_team, Ex338.FantasyTeam)
    belongs_to(:fantasy_player, Ex338.FantasyPlayer)

    timestamps()
  end

  def by_league(query, league_id) do
    from(d in query, where: d.fantasy_league_id == ^league_id)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(draft_pick, params \\ %{}) do
    draft_pick
    |> cast(params, [:draft_position, :fantasy_league_id, :fantasy_team_id, :fantasy_player_id])
    |> validate_required([:draft_position, :fantasy_league_id])
  end

  def last_picks(query, league_id, picks) do
    query
    |> by_league(league_id)
    |> preload_assocs
    |> reverse_ordered_by_position
    |> where([d], not is_nil(d.fantasy_player_id))
    |> limit(^picks)
  end

  def next_picks(query, league_id, picks) do
    query
    |> by_league(league_id)
    |> preload_assocs
    |> ordered_by_position
    |> where([d], is_nil(d.fantasy_player_id))
    |> limit(^picks)
  end

  def ordered_by_position(query) do
    from(d in query, order_by: d.draft_position)
  end

  def owner_changeset(draft_pick, params \\ %{}) do
    draft_pick
    |> cast(params, [:fantasy_player_id])
    |> validate_required([:fantasy_player_id])
  end

  def preload_assocs(query) do
    from(
      d in query,
      preload: [:fantasy_league, [fantasy_team: :owners], [fantasy_player: :sports_league]]
    )
  end

  def reverse_ordered_by_position(query) do
    from(d in query, order_by: [desc: d.draft_position])
  end
end
