defmodule Ex338.Waivers.Validate do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.{FantasyPlayers, FantasyTeams, Repo, RosterPositions.RosterPosition, ValidateHelpers}

  def add_or_drop(waiver_changeset) do
    add_player = fetch_change(waiver_changeset, :add_fantasy_player_id)
    drop_player = fetch_change(waiver_changeset, :drop_fantasy_player_id)

    do_add_or_drop(waiver_changeset, add_player, drop_player)
  end

  def before_waiver_deadline(waiver_changeset) do
    add_player = get_change(waiver_changeset, :add_fantasy_player_id)
    drop_player = get_change(waiver_changeset, :drop_fantasy_player_id)

    waiver_changeset
    |> do_before_waiver_deadline(add_player, :add_fantasy_player_id)
    |> do_before_waiver_deadline(drop_player, :drop_fantasy_player_id)
  end

  def drop_is_owned(%{changes: %{status: "invalid"}} = waiver_changeset) do
    waiver_changeset
  end

  def drop_is_owned(%{changes: %{status: "unsuccessful"}} = waiver_changeset) do
    waiver_changeset
  end

  def drop_is_owned(waiver_changeset) do
    team_id = get_field(waiver_changeset, :fantasy_team_id)
    drop_id = get_field(waiver_changeset, :drop_fantasy_player_id)

    params = [
      fantasy_team_id: team_id,
      fantasy_player_id: drop_id,
      status: "active"
    ]

    if team_id == nil || drop_id == nil do
      waiver_changeset
    else
      check_position(waiver_changeset, params)
    end
  end

  def max_flex_slots(%{changes: %{status: "invalid"}} = waiver_changeset) do
    waiver_changeset
  end

  def max_flex_slots(%{changes: %{status: "unsuccessful"}} = waiver_changeset) do
    waiver_changeset
  end

  def max_flex_slots(waiver_changeset) do
    team_id = get_field(waiver_changeset, :fantasy_team_id)
    drop_id = get_field(waiver_changeset, :drop_fantasy_player_id)
    add_id = get_field(waiver_changeset, :add_fantasy_player_id)

    if team_id == nil || add_id == nil do
      waiver_changeset
    else
      %{
        roster_positions: positions,
        max_flex_adj: max_flex_adj,
        fantasy_league: %{max_flex_spots: max_flex_spots}
      } = FantasyTeams.get_team_with_active_positions(team_id)

      max_flex_spots = max_flex_spots + max_flex_adj
      future_positions = calculate_future_positions(positions, add_id, drop_id)

      do_max_flex_slots(waiver_changeset, future_positions, max_flex_spots)
    end
  end

  def open_position(%{changes: %{drop_fantasy_player_id: _}} = waiver_changeset) do
    waiver_changeset
  end

  def open_position(waiver_changeset) do
    team_id = get_field(waiver_changeset, :fantasy_team_id)

    case team_id do
      nil ->
        waiver_changeset

      team_id ->
        RosterPosition
        |> RosterPosition.count_positions_for_team(team_id)
        |> do_open_position(waiver_changeset)
    end
  end

  def wait_period_open(waiver_changeset) do
    process_at = get_field(waiver_changeset, :process_at)
    now = Calendar.DateTime.add!(DateTime.utc_now(), -100)
    result = DateTime.compare(process_at, now)

    do_wait_period_open(waiver_changeset, result)
  end

  def within_cancellation_period(waiver_changeset) do
    submitted_at = waiver_changeset.data.inserted_at
    now = NaiveDateTime.utc_now()
    two_hours = 60 * 60 * 2
    age_of_waiver = NaiveDateTime.diff(now, submitted_at, :second)

    case age_of_waiver < two_hours do
      true -> waiver_changeset
      false -> add_error(waiver_changeset, :status, "Must cancel within two hours of submitting")
    end
  end

  ## Helpers

  ## add_or_drop

  defp do_add_or_drop(waiver_changeset, :error, :error) do
    waiver_changeset
    |> add_error(:add_fantasy_player_id, "Must submit an add or a drop")
    |> add_error(:drop_fantasy_player_id, "Must submit an add or a drop")
  end

  defp do_add_or_drop(waiver_changeset, _, _), do: waiver_changeset

  ## before_waiver_deadline

  defp do_before_waiver_deadline(waiver_changeset, player_id, _key)
       when is_nil(player_id),
       do: waiver_changeset

  defp do_before_waiver_deadline(waiver_changeset, player_id, key) do
    team_id = get_field(waiver_changeset, :fantasy_team_id)
    league_id = FantasyTeams.find(team_id).fantasy_league_id

    case FantasyPlayers.get_next_championship(
           FantasyPlayers.FantasyPlayer,
           player_id,
           league_id
         ) do
      nil ->
        add_error(waiver_changeset, key, "Claim submitted after season ended.")

      championship ->
        add_error_for_waiver_deadline(
          waiver_changeset,
          championship.waiver_deadline_at,
          key
        )
    end
  end

  defp add_error_for_waiver_deadline(waiver_changeset, waiver_deadline, key) do
    now = DateTime.utc_now()

    case DateTime.compare(waiver_deadline, now) do
      :gt -> waiver_changeset
      :eq -> waiver_changeset
      :lt -> add_error(waiver_changeset, key, "Claim submitted after waiver deadline.")
    end
  end

  ## drop_is_owned

  defp check_position(waiver_changeset, params) do
    case Repo.get_by(RosterPosition, params) do
      nil ->
        add_error(
          waiver_changeset,
          :drop_fantasy_player_id,
          "Player to drop is not on an active roster position"
        )

      _position ->
        waiver_changeset
    end
  end

  ## open_position

  defp do_open_position(count, waiver_changeset) when count >= 20 do
    add_error(
      waiver_changeset,
      :drop_fantasy_player_id,
      "No open position, must submit a player to drop"
    )
  end

  defp do_open_position(count, waiver_changeset) when count < 20 do
    waiver_changeset
  end

  # max_flex_slots

  defp calculate_future_positions(positions, add_id, drop_id) do
    add_player = FantasyPlayers.player_with_sport!(FantasyPlayers.FantasyPlayer, add_id)

    positions_with_add = positions ++ [%{fantasy_player: add_player, fantasy_player_id: add_id}]

    drop_position = Enum.find(positions_with_add, &(&1.fantasy_player_id == drop_id))

    List.delete(positions_with_add, drop_position)
  end

  defp do_max_flex_slots(waiver_changeset, future_positions, max_flex_spots) do
    case ValidateHelpers.slot_available?(future_positions, max_flex_spots) do
      true ->
        waiver_changeset

      false ->
        add_error(
          waiver_changeset,
          :add_fantasy_player_id,
          "No flex position available for this player"
        )
    end
  end

  ## wait_period_open

  defp do_wait_period_open(waiver_changeset, :gt), do: waiver_changeset
  defp do_wait_period_open(waiver_changeset, :eq), do: waiver_changeset

  defp do_wait_period_open(waiver_changeset, :lt) do
    waiver_changeset
    |> add_error(
      :add_fantasy_player_id,
      "Wait period has ended on another claim for this player."
    )
    |> add_error(:drop_fantasy_player_id, "Wait period has ended.")
  end
end
