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

  @doc false
  def changeset(%DraftQueue{} = draft_queue, attrs \\ %{}) do
    draft_queue
    |> cast(
      attrs,
      [:order, :fantasy_team_id, :fantasy_player_id, :status]
    )
    |> validate_required([:order, :fantasy_team_id, :fantasy_player_id])
  end

  def preload_assocs(query) do
    from q in query, preload: [:fantasy_team, :fantasy_player]
  end

  def owner_status_options, do: @owner_status_options

  def status_options() do
    Enum.filter(DraftQueueStatusEnum.__valid_values__(), &(is_binary(&1)))
  end
end
