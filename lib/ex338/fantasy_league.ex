defmodule Ex338.FantasyLeague do
  @moduledoc false

  use Ex338Web, :model

  @leagues [
    %{id: 1, name: "2017 Div A"},
    %{id: 2, name: "2017 Div B"},
    %{id: 4, name: "2018 Div A"},
    %{id: 5, name: "2018 Div B"},
    %{id: 6, name: "2018 Div C"},
  ]

  schema "fantasy_leagues" do
    field :fantasy_league_name, :string
    field :year, :integer
    field :division, :string
    has_many :fantasy_teams, Ex338.FantasyTeam
    has_many :draft_picks, Ex338.DraftPick
    has_many :league_sports, Ex338.LeagueSport

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:fantasy_league_name, :year, :division])
    |> validate_required([:fantasy_league_name,:year, :division])
  end

  def leagues, do: @leagues

  def by_league(query, league_id) do
    from t in query,
      where: t.fantasy_league_id == ^league_id
  end
end
