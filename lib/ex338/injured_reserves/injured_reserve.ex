defmodule Ex338.InjuredReserves.InjuredReserve do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Ex338.FantasyPlayers.FantasyPlayer
  alias Ex338.InjuredReserves.InjuredReserve

  schema "injured_reserves" do
    field(:status, InjuredReserveStatusEnum, default: "submitted")
    belongs_to(:fantasy_team, Ex338.FantasyTeams.FantasyTeam)
    belongs_to(:injured_player, FantasyPlayer)
    belongs_to(:replacement_player, FantasyPlayer)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(%InjuredReserve{} = injured_reserve, params \\ %{}) do
    injured_reserve
    |> cast(params, [
      :status,
      :fantasy_team_id,
      :injured_player_id,
      :replacement_player_id
    ])
    |> validate_required([:fantasy_team_id, :injured_player_id, :replacement_player_id, :status])
    |> validate_inclusion(:status, InjuredReserveStatusEnum.__valid_values__())
  end

  def by_league(query, league_id) do
    from(
      i in query,
      join: f in assoc(i, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      order_by: [desc: i.inserted_at]
    )
  end

  def by_status(query, statuses) when is_list(statuses) do
    from(
      i in query,
      where: i.status in ^statuses
    )
  end

  def preload_assocs(query) do
    from(
      i in query,
      preload: [
        [fantasy_team: [:owners, :fantasy_league]],
        [injured_player: :sports_league],
        [replacement_player: :sports_league]
      ]
    )
  end
end
