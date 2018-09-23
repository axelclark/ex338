defmodule Ex338.DraftPick do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.{FantasyPlayer, FantasyTeam, ValidateHelpers}

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
    |> validate_max_flex_spots()
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

  ## Helpers

  ## validate_max_flex_spots

  defp validate_max_flex_spots(draft_pick_changeset) do
    team_id = get_field(draft_pick_changeset, :fantasy_team_id)
    drafted_player_id = get_field(draft_pick_changeset, :fantasy_player_id)

    if team_id == nil || drafted_player_id == nil do
      draft_pick_changeset
    else
      %{roster_positions: positions, fantasy_league: %{max_flex_spots: max_flex_spots}} =
        FantasyTeam.Store.get_team_with_active_positions(team_id)

      future_positions = calculate_future_positions(positions, drafted_player_id)

      do_max_flex_slots(draft_pick_changeset, future_positions, max_flex_spots)
    end
  end

  defp calculate_future_positions(positions, drafted_player_id) do
    drafted_player = FantasyPlayer.Store.player_with_sport!(FantasyPlayer, drafted_player_id)

    positions ++ [%{fantasy_player: drafted_player, fantasy_player_id: drafted_player_id}]
  end

  defp do_max_flex_slots(draft_pick_changeset, future_positions, max_flex_spots) do
    case ValidateHelpers.slot_available?(future_positions, max_flex_spots) do
      true ->
        draft_pick_changeset

      false ->
        add_error(
          draft_pick_changeset,
          :fantasy_player_id,
          "No flex position available for this player"
        )
    end
  end
end
