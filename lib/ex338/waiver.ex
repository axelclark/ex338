defmodule Ex338.Waiver do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.{Waiver, FantasyTeam, Repo, CalendarAssistant,
               FantasyPlayer, Waiver.Validate}

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
    |> Validate.drop_is_owned
    |> Validate.max_flex_slots
  end

  def new_changeset(waiver_struct, params \\ %{}) do
    waiver_struct
    |> cast(params, [:fantasy_team_id, :add_fantasy_player_id,
                     :drop_fantasy_player_id, :process_at])
    |> validate_required([:fantasy_team_id])
    |> Validate.add_or_drop
    |> Validate.before_waiver_deadline
    |> set_datetime_to_process
    |> Validate.wait_period_open
    |> Validate.open_position
    |> foreign_key_constraint(:fantasy_team_id)
    |> foreign_key_constraint(:drop_fantasy_player_id)
    |> foreign_key_constraint(:add_fantasy_player_id)
  end

  def pending(query) do
    from w in query, where: w.status == "pending"
  end

  def pending_waivers_for_player(query, add_player_id, league_id) do
    query
    |> by_league(league_id)
    |> pending
    |> where([w], w.add_fantasy_player_id == ^add_player_id)
    |> limit(1)
  end

  def preload_assocs(query) do
    from w in query,
      preload: [
        [fantasy_team: :owners],
        [add_fantasy_player: :sports_league],
        [drop_fantasy_player: :sports_league]
      ]
  end

  def ready_to_process(query) do
    from w in query, where: w.process_at <= ago(0, "second")
  end

  def status_options, do: @status_options

  def update_changeset(waiver_struct, params \\ %{}) do
    waiver_struct
    |> cast(params, [:drop_fantasy_player_id])
    |> foreign_key_constraint(:drop_fantasy_player_id)
    |> Validate.wait_period_open
  end

  ## Helpers

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
        do_set_datetime_to_process(waiver_changeset, team_id, add_player)
    end
  end

  defp set_datetime_to_now(waiver_changeset) do
    put_change(waiver_changeset, :process_at, DateTime.utc_now())
  end

  defp do_set_datetime_to_process(
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

  defp do_set_datetime_to_process(waiver_changeset, team_id, add_player) do
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
end
