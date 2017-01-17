defmodule Ex338.RosterPosition do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{FantasyLeague, FantasyTeam, FantasyPlayer, Repo, ChampionshipSlot}

  @default_position ["Unassigned"]


  @flex_positions ["Flex1", "Flex2", "Flex3", "Flex4", "Flex5", "Flex6"]

  @positions ["CL", "CBB", "CFB", "CHK", "EPL", "KD", "LLWS", "MTn", "MLB",
              "NBA", "NFL", "NHL", "PGA", "WTn"] ++ @flex_positions

  @status_options ["active", "injured_reserve", "dropped", "traded"]

  schema "roster_positions" do
    belongs_to :fantasy_team, FantasyTeam
    field :position, :string
    belongs_to :fantasy_player, FantasyPlayer
    field :status, :string
    field :active_at, Ecto.DateTime
    field :released_at, Ecto.DateTime
    has_many :championship_slots, ChampionshipSlot

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:position, :fantasy_team_id, :fantasy_player_id, :status,
                     :released_at, :active_at])
    |> validate_required([:fantasy_team_id])
    |> unique_constraint(:position,
         name: :roster_positions_position_fantasy_team_id_index,
         message: "Already have a player in this position")
    |> check_constraint(:position, name: :position_not_null,
         message: "Position cannot be blank or remain Unassigned")
  end

  def positions, do: @positions

  def flex_positions, do: @flex_positions

  def all_positions, do: @positions ++ @default_position

  def status_options, do: @status_options

  def active_positions(query) do
    players_with_results = FantasyPlayer
                           |> FantasyPlayer.preload_overall_results

    from r in query,
      where: r.status == "active",
      preload: [fantasy_player: ^players_with_results]
  end

  def by_league(query, league_id) do
    from r in query,
      join: f in assoc(r, :fantasy_team),
      where: f.fantasy_league_id == ^league_id,
      where: r.status == "active",
      preload: [:fantasy_team]
  end

  def current_positions(query) do
    players_with_results = FantasyPlayer
                           |> FantasyPlayer.preload_overall_results

    from r in query,
      where: r.status == "injured_reserve" or r.status == "active",
      preload: [fantasy_player: ^players_with_results]
  end

  def update_position_status(query, team_id, player_id, released_at, status) do
    from r in query,
      where: r.fantasy_team_id   == ^team_id,
      where: r.fantasy_player_id == ^player_id,
      update: [set: [released_at: ^released_at]],
      update: [set: [status:      ^status]]
  end

  def count_positions_for_team(query, team_id) do
    query =
      from r in query,
        where: r.fantasy_team_id == ^team_id,
        where: r.status == "active"

    Repo.aggregate(query, :count, :id)
  end
end
