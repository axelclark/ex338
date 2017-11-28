defmodule Ex338.Waiver do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.{Waiver, FantasyTeam, Repo, CalendarAssistant,
               RosterPosition, FantasyPlayer}

  @status_options ["pending",
                   "successful",
                   "unsuccessful",
                   "invalid"]

  schema "waivers" do
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :add_fantasy_player, Ex338.FantasyPlayer
    belongs_to :drop_fantasy_player, Ex338.FantasyPlayer
    field :status, :string
    field :process_at, :utc_datetime

    timestamps()
  end

  def build_new_changeset(fantasy_team) do
      fantasy_team
      |> build_assoc(:waivers)
      |> new_changeset
  end

  def by_league(query, league_id) do
    from w in query,
      join: f in assoc(w, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      order_by: [asc: w.process_at, asc: f.waiver_position]
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(waiver_struct, params \\ %{}) do
    waiver_struct
    |> cast(params, [:status, :fantasy_team_id, :add_fantasy_player_id,
                     :drop_fantasy_player_id, :process_at])
    |> validate_required([:fantasy_team_id])
    |> validate_inclusion(:status, @status_options)
  end

  def new_changeset(waiver_struct, params \\ %{}) do
    waiver_struct
    |> cast(params, [:fantasy_team_id, :add_fantasy_player_id,
                     :drop_fantasy_player_id, :process_at])
    |> validate_required([:fantasy_team_id])
    |> validate_add_or_drop
    |> validate_before_waiver_deadline
    |> set_datetime_to_process
    |> validate_wait_period_open
    |> validate_open_position
    |> foreign_key_constraint(:fantasy_team_id)
    |> foreign_key_constraint(:drop_fantasy_player_id)
    |> foreign_key_constraint(:add_fantasy_player_id)
  end

  def pending_waivers_for_player(query, add_player_id, league_id) do
    from w in by_league(query, league_id),
      where: w.status == "pending" and
             w.add_fantasy_player_id == ^add_player_id,
      limit: 1
  end

  def status_options, do: @status_options

  def update_changeset(waiver_struct, params \\ %{}) do
    waiver_struct
    |> cast(params, [:drop_fantasy_player_id])
    |> foreign_key_constraint(:drop_fantasy_player_id)
    |> validate_wait_period_open
  end

  ## Helpers

  defp validate_wait_period_open(waiver_changeset) do
    process_at = get_field(waiver_changeset, :process_at)
    now        = Calendar.DateTime.add!(DateTime.utc_now(), -100)
    result     = DateTime.compare(process_at, now)

    validate_wait_period_open(waiver_changeset, result)
  end

  defp validate_wait_period_open(waiver_changeset, :gt), do: waiver_changeset
  defp validate_wait_period_open(waiver_changeset, :eq), do: waiver_changeset
  defp validate_wait_period_open(waiver_changeset, :lt) do
      waiver_changeset
      |> add_error(:add_fantasy_player_id,
           "Wait period has ended on another claim for this player.")
      |> add_error(:drop_fantasy_player_id,
           "Wait period has ended.")
  end

  ## Implementations

  ## new_changeset

  defp set_datetime_to_process(waiver_changeset) do
    team_id = get_field(waiver_changeset, :fantasy_team_id)
    case get_change(waiver_changeset, :add_fantasy_player_id) do
      nil ->
        set_datetime_to_now(waiver_changeset)
      id ->
        add_player =
          FantasyPlayer.Store.player_with_sport!(FantasyPlayer, id)
        set_datetime_to_process(waiver_changeset, team_id, add_player)
    end
  end

  defp set_datetime_to_now(waiver_changeset) do
    put_change(waiver_changeset, :process_at, DateTime.utc_now())
  end

  defp set_datetime_to_process(
    waiver_changeset,
    team_id,
    %{sports_league: %{hide_waivers: true}} = add_player
  ) do

    league_id = FantasyTeam.Store.find(team_id).fantasy_league_id

    process_at =
      case FantasyPlayer.Store.get_next_championship(
        FantasyPlayer,
        add_player.id,
        league_id
      ) do
        nil -> CalendarAssistant.days_from_now(3)
        championship -> championship.waiver_deadline_at
      end

    put_change(waiver_changeset, :process_at, process_at)
  end

  defp set_datetime_to_process(waiver_changeset, team_id, add_player) do
    process_at =
      get_existing_waiver_date(team_id, add_player.id) ||
        CalendarAssistant.days_from_now(3)

    put_change(waiver_changeset, :process_at, process_at)
  end

  defp get_existing_waiver_date(fantasy_team_id, add_player_id) do
    league_id = FantasyTeam.Store.find(fantasy_team_id).fantasy_league_id

    waiver =
      Waiver
      |> pending_waivers_for_player(add_player_id, league_id)
      |> Repo.one

    case waiver do
      nil    -> false
      waiver -> waiver.process_at
    end
  end

  defp validate_add_or_drop(waiver_changeset) do
    add  = fetch_change(waiver_changeset, :add_fantasy_player_id)
    drop = fetch_change(waiver_changeset, :drop_fantasy_player_id)

    validate_add_or_drop(waiver_changeset, add, drop)
  end

  defp validate_add_or_drop(waiver_changeset, :error, :error) do
    waiver_changeset
    |> add_error(:add_fantasy_player_id, "Must submit an add or a drop")
    |> add_error(:drop_fantasy_player_id, "Must submit an add or a drop")
  end

  defp validate_add_or_drop(waiver_changeset, _, _), do: waiver_changeset

  defp validate_before_waiver_deadline(waiver_changeset) do
    add_player  = get_change(waiver_changeset, :add_fantasy_player_id)
    drop_player  = get_change(waiver_changeset, :drop_fantasy_player_id)

    waiver_changeset
    |> validate_before_waiver_deadline(add_player, :add_fantasy_player_id)
    |> validate_before_waiver_deadline(drop_player, :drop_fantasy_player_id)
  end

  defp validate_before_waiver_deadline(waiver_changeset, player_id, _key)
    when is_nil(player_id), do: waiver_changeset

  defp validate_before_waiver_deadline(waiver_changeset, player_id, key) do
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

  defp validate_open_position(%{changes: %{drop_fantasy_player_id: _}} =
    waiver_changeset), do: waiver_changeset

  defp validate_open_position(waiver_changeset) do
      team_id = get_field(waiver_changeset, :fantasy_team_id)

      case team_id do
        nil -> waiver_changeset
        team_id -> RosterPosition
                   |> RosterPosition.count_positions_for_team(team_id)
                   |> validate_open_position(waiver_changeset)
      end
  end

  defp validate_open_position(count, waiver_changeset) when count >= 20 do
    waiver_changeset
    |> add_error(:drop_fantasy_player_id,
         "No open position, must submit a player to drop")
  end

  defp validate_open_position(count, waiver_changeset) when count < 20 do
    waiver_changeset
  end
end
