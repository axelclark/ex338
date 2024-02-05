defmodule Ex338.DraftPicks.DraftPick do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Ex338.DraftPicks
  alias Ex338.FantasyPlayers
  alias Ex338.FantasyTeams
  alias Ex338.ValidateHelpers

  schema "draft_picks" do
    field(:draft_position, :float)
    field(:seconds_on_the_clock, :integer, virtual: true)
    field(:pick_number, :integer, virtual: true)
    field(:drafted_at, :utc_datetime)
    field(:available_to_pick?, :boolean, virtual: true, default: false)
    belongs_to(:fantasy_league, Ex338.FantasyLeagues.FantasyLeague)
    belongs_to(:fantasy_team, Ex338.FantasyTeams.FantasyTeam)
    belongs_to(:fantasy_player, Ex338.FantasyPlayers.FantasyPlayer)

    timestamps()
  end

  def add_pick_numbers(draft_picks) do
    for {draft_pick, counter} <- Enum.with_index(draft_picks) do
      %{draft_pick | pick_number: counter + 1}
    end
  end

  def update_available_to_pick?(draft_picks) do
    Enum.map(draft_picks, fn draft_pick ->
      %{draft_pick | available_to_pick?: available_to_pick?(draft_picks, draft_pick)}
    end)
  end

  def available_with_skipped_picks?(draft_pick_id, draft_picks) do
    remaining_picks = remove_completed_picks(draft_picks)

    case find_index_of_next_team_under_limit(remaining_picks) do
      nil ->
        false

      index_next_team_under_limit ->
        remaining_picks
        |> get_available_picks(index_next_team_under_limit)
        |> draft_pick_available?(draft_pick_id)
    end
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
    |> unique_constraint(:fantasy_player_id,
      name: :draft_picks_fantasy_league_id_fantasy_player_id_index,
      message: "Player already drafted in the league"
    )
  end

  def picks_available_with_skips(draft_picks) do
    remaining_picks = remove_completed_picks(draft_picks)

    case find_index_of_next_team_under_limit(remaining_picks) do
      nil ->
        nil

      index_next_team_under_limit ->
        get_available_picks(remaining_picks, index_next_team_under_limit)
    end
  end

  def last_picks(query, league_id, picks) do
    query
    |> by_league(league_id)
    |> preload_assocs()
    |> reverse_ordered_by_position()
    |> where([d], not is_nil(d.fantasy_player_id))
    |> limit(^picks)
  end

  def next_picks(query, league_id, picks) do
    query
    |> by_league(league_id)
    |> preload_assocs()
    |> ordered_by_position()
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
    |> validate_pick_is_up()
    |> validate_max_flex_spots()
    |> validate_players_available_for_league()
    |> add_drafted_at()
    |> unique_constraint(:fantasy_player_id,
      name: :draft_picks_fantasy_league_id_fantasy_player_id_index,
      message: "Player already drafted in the league"
    )
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

  def validate_max_flex_spots(%{changes: %{status: status}} = draft_pick_changeset)
      when status in [:cancelled, :unavailable] do
    draft_pick_changeset
  end

  def validate_max_flex_spots(draft_pick_changeset) do
    team_id = get_field(draft_pick_changeset, :fantasy_team_id)
    drafted_player_id = get_field(draft_pick_changeset, :fantasy_player_id)

    if team_id == nil || drafted_player_id == nil do
      draft_pick_changeset
    else
      %{roster_positions: positions, fantasy_league: %{max_flex_spots: max_flex_spots}} =
        FantasyTeams.get_team_with_active_positions(team_id)

      future_positions = calculate_future_positions(positions, drafted_player_id)

      do_max_flex_slots(draft_pick_changeset, future_positions, max_flex_spots)
    end
  end

  def validate_players_available_for_league(draft_pick_changeset) do
    with team when not is_nil(team) <- get_team(draft_pick_changeset),
         %{must_draft_each_sport?: true} <- team.fantasy_league,
         drafted_player_id when not is_nil(drafted_player_id) <-
           get_field(draft_pick_changeset, :fantasy_player_id),
         {:ok, teams_needing_player} <-
           get_teams_needing_player(team, drafted_player_id),
         {:ok, :add_error_to_changeset} <-
           compare_teams_to_players(teams_needing_player, drafted_player_id, team) do
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

  ## Helpers

  ## update_available_to_pick?

  def available_to_pick?(draft_picks, draft_pick) do
    next_pick?(draft_picks, draft_pick) ||
      available_with_skipped_picks?(draft_pick.id, draft_picks)
  end

  defp next_pick?(draft_picks, draft_pick) do
    Enum.find(draft_picks, &(&1.fantasy_player_id == nil)) == draft_pick
  end

  ## available_with_skipped_picks?

  defp remove_completed_picks(draft_picks) do
    Enum.drop_while(draft_picks, &(&1.fantasy_player_id !== nil))
  end

  defp find_index_of_next_team_under_limit(remaining_picks) do
    Enum.find_index(
      remaining_picks,
      &(&1.fantasy_team.over_draft_time_limit? == false && &1.fantasy_player_id == nil)
    )
  end

  defp get_available_picks(remaining_picks, index_next_team_under_limit) do
    remaining_picks
    |> Enum.take(index_next_team_under_limit + 1)
    |> Enum.reject(&(&1.fantasy_player_id !== nil))
  end

  defp draft_pick_available?(available_picks, draft_pick_id) do
    available_picks
    |> Enum.map(& &1.id)
    |> Enum.any?(&(&1 == draft_pick_id))
  end

  ## owner_changeset

  defp add_drafted_at(changeset) do
    now = DateTime.truncate(DateTime.utc_now(), :second)
    put_change(changeset, :drafted_at, now)
  end

  ## validate_is_next_pick

  defp validate_pick_is_up(draft_pick_changeset) do
    with fantasy_league_id when not is_nil(fantasy_league_id) <-
           get_field(draft_pick_changeset, :fantasy_league_id),
         next_pick_id = get_next_pick_id(fantasy_league_id),
         :error <- is_next_pick?(draft_pick_changeset.data.id, next_pick_id),
         %{draft_picks: draft_picks} <- DraftPicks.get_picks_for_league(fantasy_league_id),
         false <- available_with_skipped_picks?(draft_pick_changeset.data.id, draft_picks) do
      add_error(draft_pick_changeset, :fantasy_player_id, "You don't have the next pick")
    else
      _ -> draft_pick_changeset
    end
  end

  defp get_next_pick_id(league_id) do
    case DraftPicks.get_next_picks(league_id, 1) do
      [] -> :none
      [next_pick] -> next_pick.id
    end
  end

  defp is_next_pick?(next_pick_id, next_pick_id), do: {:ok, next_pick_id}

  defp is_next_pick?(_other_pick_id, _next_pick_id), do: :error

  ## validate_max_flex_spots

  defp calculate_future_positions(positions, drafted_player_id) do
    drafted_player =
      FantasyPlayers.player_with_sport!(FantasyPlayers.FantasyPlayer, drafted_player_id)

    positions ++ [%{fantasy_player: drafted_player, fantasy_player_id: drafted_player_id}]
  end

  defp do_max_flex_slots(draft_pick_changeset, future_positions, max_flex_spots) do
    if ValidateHelpers.slot_available?(future_positions, max_flex_spots) do
      draft_pick_changeset
    else
      add_error(
        draft_pick_changeset,
        :fantasy_player_id,
        "No flex position available for this player"
      )
    end
  end

  ## validate_players_available_for_league

  defp get_team(draft_pick_changeset) do
    case get_field(draft_pick_changeset, :fantasy_team) do
      nil -> get_team_from_id(draft_pick_changeset)
      team -> team
    end
  end

  defp get_team_from_id(draft_pick_changeset) do
    case get_field(draft_pick_changeset, :fantasy_team_id) do
      nil -> nil
      team_id -> FantasyTeams.find(team_id)
    end
  end

  defp get_teams_needing_player(_team, nil), do: :error

  defp get_teams_needing_player(team, drafted_player_id) do
    drafted_player =
      FantasyPlayers.player_with_sport!(FantasyPlayers.FantasyPlayer, drafted_player_id)

    %{sports_league_id: sport_id} = drafted_player
    %{fantasy_league_id: league_id} = team

    teams_needing_players = FantasyTeams.without_player_from_sport(league_id, sport_id)

    if drafting_team_needs_player?(teams_needing_players, team.id) do
      {:error, :team_needs_player}
    else
      {:ok, teams_needing_players}
    end
  end

  defp drafting_team_needs_player?(teams_needing_players, team_id) do
    Enum.any?(teams_needing_players, &(&1.id == team_id))
  end

  defp compare_teams_to_players(teams_needing_players, drafted_player_id, team) do
    drafted_player =
      FantasyPlayers.player_with_sport!(FantasyPlayers.FantasyPlayer, drafted_player_id)

    %{sports_league_id: sport_id} = drafted_player
    %{fantasy_league_id: league_id} = team

    player_count = count_avail_players(drafted_player, league_id, sport_id)
    teams_with_need_count = Enum.count(teams_needing_players)

    if teams_with_need_count >= player_count do
      {:ok, :add_error_to_changeset}
    else
      {:error, :enough_players_available}
    end
  end

  defp count_avail_players(%{draft_pick: false}, league_id, sport_id) do
    league_id
    |> FantasyPlayers.get_avail_players_for_sport(sport_id)
    |> Enum.count()
  end

  defp count_avail_players(%{draft_pick: true}, league_id, sport_id) do
    league_id
    |> FantasyPlayers.get_avail_draft_pick_players_for_sport(sport_id)
    |> Enum.count()
  end
end
