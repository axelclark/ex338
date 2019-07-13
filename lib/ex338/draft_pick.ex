defmodule Ex338.DraftPick do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.{DraftPick, FantasyPlayer, FantasyTeam, ValidateHelpers}

  schema "draft_picks" do
    field(:draft_position, :float, scale: 3)
    field(:seconds_on_the_clock, :integer, virtual: true)
    field(:drafted_at, :utc_datetime)
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
    |> cast(params, [
      :drafted_at,
      :draft_position,
      :fantasy_league_id,
      :fantasy_team_id,
      :fantasy_player_id
    ])
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
    |> validate_is_next_pick()
    |> validate_max_flex_spots()
    |> validate_players_available_for_league()
    |> add_drafted_at()
  end

  def preload_assocs(query) do
    from(
      d in query,
      preload: [
        :fantasy_league,
        [fantasy_team: [:owners, :fantasy_league]],
        [fantasy_player: :sports_league]
      ]
    )
  end

  def reverse_ordered_by_position(query) do
    from(d in query, order_by: [desc: d.draft_position])
  end

  ## Helpers

  ## owner_changeset

  defp add_drafted_at(changeset) do
    put_change(changeset, :drafted_at, DateTime.utc_now())
  end

  ## validate_is_next_pick

  defp validate_is_next_pick(draft_pick_changeset) do
    with league_id when not is_nil(league_id) <-
           get_field(draft_pick_changeset, :fantasy_league_id),
         next_pick_id <- get_next_pick_id(league_id),
         :error <- is_next_pick?(draft_pick_changeset.data.id, next_pick_id) do
      add_error(draft_pick_changeset, :fantasy_player_id, "You don't have the next pick")
    else
      _ -> draft_pick_changeset
    end
  end

  defp get_next_pick_id(league_id) do
    case DraftPick.Store.get_next_picks(league_id, 1) do
      [] -> :none
      [next_pick] -> next_pick.id
    end
  end

  defp is_next_pick?(next_pick_id, next_pick_id), do: {:ok, next_pick_id}

  defp is_next_pick?(_other_pick_id, _next_pick_id), do: :error

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

  ## validate_players_available_for_league

  defp validate_players_available_for_league(draft_pick_changeset) do
    with team when not is_nil(team) <- get_field(draft_pick_changeset, :fantasy_team),
         drafted_player_id when not is_nil(drafted_player_id) <-
           get_field(draft_pick_changeset, :fantasy_player_id),
         {:ok, teams_needing_player, sport_id} <-
           get_teams_needing_player(team, drafted_player_id),
         {:ok, :add_error_to_changeset} <-
           compare_teams_to_players(teams_needing_player, sport_id, team) do
      add_error(
        draft_pick_changeset,
        :fantasy_player_id,
        "Number of available players equal to number of teams with need"
      )
    else
      _ ->
        draft_pick_changeset
    end
  end

  defp get_teams_needing_player(_team, nil), do: :error

  defp get_teams_needing_player(team, drafted_player_id) do
    drafted_player = FantasyPlayer.Store.player_with_sport!(FantasyPlayer, drafted_player_id)
    %{sports_league_id: sport_id} = drafted_player
    %{fantasy_league_id: league_id} = team

    teams_needing_players = FantasyTeam.Store.without_player_from_sport(league_id, sport_id)

    case drafting_team_needs_player?(teams_needing_players, team.id) do
      false -> {:ok, teams_needing_players, sport_id}
      true -> {:error, :team_needs_player}
    end
  end

  defp drafting_team_needs_player?(teams_needing_players, team_id) do
    Enum.any?(teams_needing_players, &(&1.id == team_id))
  end

  defp compare_teams_to_players(teams_needing_players, sport_id, team) do
    %{fantasy_league_id: league_id} = team
    player_count = count_avail_players(league_id, sport_id)
    teams_with_need_count = Enum.count(teams_needing_players)

    case teams_with_need_count >= player_count do
      true -> {:ok, :add_error_to_changeset}
      false -> {:error, :enough_players_available}
    end
  end

  defp count_avail_players(league_id, sport_id) do
    league_id
    |> FantasyPlayer.Store.get_avail_players_for_sport(sport_id)
    |> Enum.count()
  end
end
