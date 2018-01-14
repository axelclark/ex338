defmodule Ex338.DraftQueue do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Ex338.DraftQueue

  schema "draft_queues" do
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :championship, Ex338.Championship
    field :order, :integer
    belongs_to :fantasy_player, Ex338.FantasyPlayer
    field :status, DraftQueueStatusEnum, default: "pending"

    timestamps()
  end

  @doc false
  def changeset(%DraftQueue{} = draft_queue, attrs) do
    draft_queue
    |> cast(
      attrs,
      [:order, :fantasy_team_id, :fantasy_player_id, :championship_id, :status]
    )
    |> validate_required([:order, :fantasy_team_id, :fantasy_player_id])
  end

  def status_options() do
    Enum.filter(DraftQueueStatusEnum.__valid_values__(), &(is_binary(&1)))
  end
end
