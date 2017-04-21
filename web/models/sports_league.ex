defmodule Ex338.SportsLeague do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.Championship

  schema "sports_leagues" do
    field :league_name, :string
    field :abbrev, :string
    field :hide_waivers, :boolean
    has_many :fantasy_players, Ex338.FantasyPlayer
    has_many :championships, Ex338.Championship
    has_many :league_sports, Ex338.LeagueSport

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:league_name, :abbrev, :hide_waivers])
    |> validate_required([:league_name, :abbrev])
  end

  def alphabetical(query) do
    from s in query, order_by: s.league_name
  end

  def preload_overall_championships(query) do
    overall_championships =
      Championship.overall_championships(Championship)

    from s in query,
      preload: [championships: ^overall_championships]
  end
end
