defmodule Ex338.Waiver.Validate do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.{FantasyPlayer, FantasyTeam, RosterPosition, Repo}

  def add_or_drop(waiver_changeset) do
    add_player  = fetch_change(waiver_changeset, :add_fantasy_player_id)
    drop_player = fetch_change(waiver_changeset, :drop_fantasy_player_id)

    do_add_or_drop(waiver_changeset, add_player, drop_player)
  end

  def before_waiver_deadline(waiver_changeset) do
    add_player  = get_change(waiver_changeset, :add_fantasy_player_id)
    drop_player  = get_change(waiver_changeset, :drop_fantasy_player_id)

    waiver_changeset
    |> do_before_waiver_deadline(add_player, :add_fantasy_player_id)
    |> do_before_waiver_deadline(drop_player, :drop_fantasy_player_id)
  end

  def drop_is_owned(
    %{changes: %{status: "invalid"}} = waiver_changeset
  ) do
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

  def open_position(
    %{changes: %{drop_fantasy_player_id: _}} =waiver_changeset
  ) do
    waiver_changeset
  end

  def open_position(waiver_changeset) do
    team_id = get_field(waiver_changeset, :fantasy_team_id)

    case team_id do
      nil -> waiver_changeset
      team_id -> RosterPosition
      |> RosterPosition.count_positions_for_team(team_id)
      |> do_open_position(waiver_changeset)
    end
  end

  def wait_period_open(waiver_changeset) do
    process_at = get_field(waiver_changeset, :process_at)
    now        = Calendar.DateTime.add!(DateTime.utc_now(), -100)
    result     = DateTime.compare(process_at, now)

    do_wait_period_open(waiver_changeset, result)
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
    when is_nil(player_id), do: waiver_changeset

  defp do_before_waiver_deadline(waiver_changeset, player_id, key) do
    team_id = get_field(waiver_changeset, :fantasy_team_id)
    league_id = FantasyTeam.Store.find(team_id).fantasy_league_id

    case FantasyPlayer.Store.get_next_championship(
      FantasyPlayer,
      player_id,
      league_id
    ) do
      nil -> add_error(waiver_changeset, key, "Claim submitted after season ended.")

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
    waiver_changeset
    |> add_error(:drop_fantasy_player_id,
         "No open position, must submit a player to drop")
  end

  defp do_open_position(count, waiver_changeset) when count < 20 do
    waiver_changeset
  end

  ## wait_period_open

  defp do_wait_period_open(waiver_changeset, :gt), do: waiver_changeset
  defp do_wait_period_open(waiver_changeset, :eq), do: waiver_changeset
  defp do_wait_period_open(waiver_changeset, :lt) do
      waiver_changeset
      |> add_error(:add_fantasy_player_id,
           "Wait period has ended on another claim for this player.")
      |> add_error(:drop_fantasy_player_id,
           "Wait period has ended.")
  end
end
