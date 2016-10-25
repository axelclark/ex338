defmodule Ex338.FantasyLeague do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{FantasyLeague, FantasyTeam, DraftPick, Repo}

  schema "fantasy_leagues" do
    field :fantasy_league_name, :string
    field :year, :integer
    field :division, :string
    has_many :fantasy_teams, FantasyTeam
    has_many :draft_picks, DraftPick

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

  def by_league(query, league_id) do
    from t in query,
      where: t.fantasy_league_id == ^league_id
  end

  def get_league(league_id) do
    FantasyLeague |> Repo.get(league_id)
  end
end
