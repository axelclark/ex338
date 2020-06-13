defmodule Ex338.FantasyPlayers.SportsLeague do
  @moduledoc false

  use Ex338Web, :model

  alias Ex338.Championships.Championship

  schema "sports_leagues" do
    field(:league_name, :string)
    field(:abbrev, :string)
    field(:hide_waivers, :boolean)
    has_many(:fantasy_players, Ex338.FantasyPlayers.FantasyPlayer)
    has_many(:championships, Ex338.Championships.Championship)
    has_many(:league_sports, Ex338.LeagueSport)

    timestamps()
  end

  def abbrev_a_to_z(query) do
    from(s in query, order_by: s.abbrev)
  end

  def alphabetical(query) do
    from(s in query, order_by: s.league_name)
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:league_name, :abbrev, :hide_waivers])
    |> validate_required([:league_name, :abbrev])
  end

  def for_league(query, fantasy_league_id) do
    from(
      s in query,
      inner_join: ls in assoc(s, :league_sports),
      where: ls.fantasy_league_id == ^fantasy_league_id
    )
  end

  def preload_league_overall_championships(query, fantasy_league_id) do
    championships =
      Championship
      |> Championship.overall_championships()
      |> Championship.all_for_league(fantasy_league_id)

    from(s in query, preload: [championships: ^championships])
  end

  def select_abbrev(query) do
    from(s in query, select: s.abbrev)
  end
end
