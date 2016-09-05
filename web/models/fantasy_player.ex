defmodule Ex338.FantasyPlayer do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{SportsLeague, DraftPick, Waiver, RosterPosition}

  schema "fantasy_players" do
    field :player_name, :string
    belongs_to :sports_league, SportsLeague
    has_many :roster_positions, RosterPosition
    has_many :fantasy_teams, through: [:roster_positions, :fantasy_team]
    has_many :draft_picks, DraftPick
    has_many :waiver_adds, Waiver, foreign_key: :add_fantasy_player_id
    has_many :waivers_drops, Waiver, foreign_key: :drop_fantasy_player_id

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:player_name, :sports_league_id])
    |> validate_required([:player_name, :sports_league_id])
  end

  def alphabetical_by_league(query) do
    from f in query,
      join: s in assoc(f, :sports_league),
      order_by: [s.league_name, f.player_name]
  end

  def names_and_ids(query) do
    from f in query, select: {f.player_name, f.id}
  end
end
