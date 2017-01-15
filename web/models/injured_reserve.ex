defmodule Ex338.InjuredReserve do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{Repo}

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
  def changeset(ir_struct, params \\ %{}) do
    ir_struct
    |> cast(params, [:status, :fantasy_team_id, :add_player_id,
                     :remove_player_id, :replacement_player_id])
    |> validate_required([:fantasy_team_id, :status])
  end

  def status_options, do: @status_options

  def get_all_actions(query, league_id) do
    query
    |> by_league(league_id)
    |> preload([[fantasy_team: :owners], [add_player: :sports_league],
               [remove_player: :sports_league],
               [replacement_player: :sports_league]])
    |> Repo.all
  end

  def by_league(query, league_id) do
    from i in query,
      join: f in assoc(i, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      order_by: [desc: i.inserted_at]
  end
end
