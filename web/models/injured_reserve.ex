defmodule Ex338.InjuredReserve do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{Repo, InjuredReserve}

  @status_options ["pending",
                   "approved",
                   "invalid"]

  schema "injured_reserves" do
    field :status, :string
    belongs_to :fantasy_team, Ex338.FantasyTeam
    belongs_to :add_player, Ex338.FantasyPlayer
    belongs_to :remove_player, Ex338.FantasyPlayer
    belongs_to :replacement_player, Ex338.FantasyPlayer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(%InjuredReserve{} = injured_reserve, params \\ %{}) do
    injured_reserve
    |> cast(params, [:status, :fantasy_team_id, :add_player_id,
                     :remove_player_id, :replacement_player_id])
    |> validate_required([:fantasy_team_id, :status])
  end

  def status_options, do: @status_options

  def by_league(query, league_id) do
    from i in query,
      join: f in assoc(i, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      order_by: [desc: i.inserted_at]
  end

  def preload_assocs(query) do
    from i in query,
      preload: [
        [fantasy_team: :owners], [add_player: :sports_league],
        [remove_player: :sports_league],
        [replacement_player: :sports_league]
      ]
  end
end
