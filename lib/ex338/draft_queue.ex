defmodule Ex338.DraftQueue do
  @moduledoc false
  use Ecto.Schema
  use Ex338Web, :model
  import Ecto.Changeset
  alias Ex338.DraftQueue

  @owner_status_options ["pending", "cancelled"]

  schema "draft_queues" do
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :fantasy_player, Ex338.FantasyPlayer
    field :order, :integer
    field :status, DraftQueueStatusEnum, default: "pending"

    timestamps()
  end

  def by_league(query, fantasy_league_id) do
    from q in query,
      join: f in assoc(q, :fantasy_team),
      where: f.fantasy_league_id == ^fantasy_league_id
  end

  def by_player(query, fantasy_player_id) do
    from q in query, where: q.fantasy_player_id == ^fantasy_player_id
  end

  def by_team(query, fantasy_team_id) do
    from q in query, where: q.fantasy_team_id == ^fantasy_team_id
  end

  @doc false
  def changeset(%DraftQueue{} = draft_queue, attrs \\ %{}) do
    draft_queue
    |> cast(
      attrs,
      [:order, :fantasy_team_id, :fantasy_player_id, :status]
    )
    |> validate_required([:order, :fantasy_team_id, :fantasy_player_id])
  end

  def except_team(query, fantasy_team_id) do
    from q in query, where: q.fantasy_team_id != ^fantasy_team_id
  end

  def only_pending(query) do
    from q in query, where: q.status == "pending"
  end

  def preload_assocs(query) do
    from q in query, preload: [:fantasy_team, :fantasy_player]
  end

  def owner_status_options, do: @owner_status_options

  def status_options() do
    Enum.filter(DraftQueueStatusEnum.__valid_values__(), &(is_binary(&1)))
  end

  def update_to_drafted(query) do
    from q in query, update: [set: [status: "drafted"]]
  end

  def update_to_unavailable(query) do
    from q in query, update: [set: [status: "unavailable"]]
  end
end
