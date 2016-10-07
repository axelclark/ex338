defmodule Ex338.Waiver do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{Waiver, WaiverAdmin, FantasyTeam, Repo, CalendarAssistant}

  @status_options ["pending",
                   "successful",
                   "unsuccessful",
                   "invalid"]

  schema "waivers" do
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :add_fantasy_player, Ex338.FantasyPlayer
    belongs_to :drop_fantasy_player, Ex338.FantasyPlayer
    field :status, :string
    field :process_at, Ecto.DateTime

    timestamps()
  end

  def status_options, do: @status_options

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:status, :fantasy_team_id, :add_fantasy_player_id,
                     :drop_fantasy_player_id])
    |> validate_required([:fantasy_team_id])
  end

  def new_changeset(waiver_struct, params \\ %{}) do
    waiver_struct
    |> cast(params, [:fantasy_team_id, :add_fantasy_player_id,
                     :drop_fantasy_player_id, :process_at])
    |> validate_required([:fantasy_team_id])
    |> validate_add_or_drop
    |> set_datetime_to_process
    |> validate_wait_period_open
    |> foreign_key_constraint(:fantasy_team_id)
    |> foreign_key_constraint(:drop_fantasy_player_id)
    |> foreign_key_constraint(:add_fantasy_player_id)
  end

  def by_league(query, league_id) do
    from w in query,
      join: f in assoc(w, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      order_by: [asc: w.process_at, asc: f.waiver_position]
  end

  def pending_waivers_for_player(query, add_player_id, league_id) do
    from w in by_league(query, league_id),
      where: w.status == "pending" and
             w.add_fantasy_player_id == ^add_player_id,
      limit: 1
  end

  def update_waiver(waiver, params) do
    waiver
    |> WaiverAdmin.process_waiver(params)
    |> Repo.transaction
  end

  defp set_datetime_to_process(waiver_changeset) do
    team_id       = get_field(waiver_changeset, :fantasy_team_id)
    add_player_id = get_change(waiver_changeset, :add_fantasy_player_id)

    set_datetime_to_process(waiver_changeset, team_id, add_player_id)
  end

  defp set_datetime_to_process(waiver_changeset, _, nil) do
    put_change(waiver_changeset, :process_at, Ecto.DateTime.utc)
  end

  defp set_datetime_to_process(waiver_changeset, team_id, add_player_id) do
    process_at =
      get_existing_waiver_date(team_id, add_player_id) ||
        CalendarAssistant.days_from_now(3)

    put_change(waiver_changeset, :process_at, process_at)
  end

  defp get_existing_waiver_date(fantasy_team_id, add_player_id) do
    league_id = Repo.get!(FantasyTeam, fantasy_team_id).fantasy_league_id

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

  def validate_wait_period_open(waiver_changeset) do
    process_at = get_change(waiver_changeset, :process_at)
    now        = Ecto.DateTime.utc

    validate_wait_period_open(waiver_changeset, process_at, now)
  end

  defp validate_wait_period_open(waiver_changeset, process_at, now)
    when process_at >= now, do: waiver_changeset

  defp validate_wait_period_open(waiver_changeset, process_at, now)
    when process_at < now do
    add_error(waiver_changeset, :add_fantasy_player_id,
     "Existing waiver and wait period has already ended.")
  end
end
