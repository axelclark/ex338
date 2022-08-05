defmodule Ex338.DraftQueues.DraftQueue do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false
  import Ecto.Changeset
  alias Ex338.{DraftQueues.DraftQueue, DraftPicks.DraftPick, FantasyTeams}

  @owner_status_options ["pending", "cancelled"]

  schema "draft_queues" do
    belongs_to(:fantasy_team, Ex338.FantasyTeams.FantasyTeam)
    belongs_to(:fantasy_player, Ex338.FantasyPlayers.FantasyPlayer)
    field(:order, :integer)
    field(:status, DraftQueueStatusEnum, default: "pending")

    timestamps()
  end

  def by_id(query, id) do
    from(q in query, where: q.id == ^id)
  end

  def by_league(query, fantasy_league_id) do
    from(
      q in query,
      join: f in assoc(q, :fantasy_team),
      where: f.fantasy_league_id == ^fantasy_league_id
    )
  end

  def by_player(query, fantasy_player_id) do
    from(q in query, where: q.fantasy_player_id == ^fantasy_player_id)
  end

  def by_sport(query, sport_id) do
    from(
      q in query,
      join: p in assoc(q, :fantasy_player),
      where: p.sports_league_id == ^sport_id
    )
  end

  def by_team(query, fantasy_team_id) do
    from(q in query, where: q.fantasy_team_id == ^fantasy_team_id)
  end

  @doc false
  def changeset(%DraftQueue{} = draft_queue, attrs \\ %{}) do
    draft_queue
    |> cast(attrs, [:order, :fantasy_team_id, :fantasy_player_id, :status])
    |> validate_required([:order, :fantasy_team_id, :fantasy_player_id])
    |> maybe_validate_max_flex_spots()

    # |> DraftPick.validate_players_available_for_league()
  end

  defp maybe_validate_max_flex_spots(changeset) do
    with team_id when not is_nil(team_id) <- fetch_field!(changeset, :fantasy_team_id),
         team <- FantasyTeams.find(team_id),
         nil <- team.fantasy_league.sport_draft_id do
      DraftPick.validate_max_flex_spots(changeset)
    else
      _ -> changeset
    end
  end

  def except_team(query, fantasy_team_id) do
    from(q in query, where: q.fantasy_team_id != ^fantasy_team_id)
  end

  def only_pending(query) do
    from(q in query, where: q.status == "pending")
  end

  def ordered(query) do
    from(q in query, order_by: q.order)
  end

  def owner_status_options, do: @owner_status_options

  def preload_assocs(query) do
    from(q in query, preload: [:fantasy_team, :fantasy_player])
  end

  def status_options() do
    Enum.filter(DraftQueueStatusEnum.__valid_values__(), &is_binary(&1))
  end

  def update_order(query, order) do
    from(q in query, update: [set: [order: ^order]])
  end

  def update_to_drafted(query) do
    from(q in query, update: [set: [status: "drafted"]])
  end

  def update_to_unavailable(query) do
    from(q in query, update: [set: [status: "unavailable"]])
  end
end
