defmodule Ex338.FantasyLeague do
  @moduledoc false

  use Ex338Web, :model

  schema "fantasy_leagues" do
    field(:fantasy_league_name, :string)
    field(:year, :integer)
    field(:division, :string)
    field(:navbar_display, FantasyLeagueNavbarDisplayEnum, default: "primary")
    belongs_to(:sport_draft, Ex338.SportsLeague)
    has_many(:fantasy_teams, Ex338.FantasyTeam)
    has_many(:draft_picks, Ex338.DraftPick)
    has_many(:league_sports, Ex338.LeagueSport)

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:fantasy_league_name, :year, :division, :sport_draft_id, :navbar_display])
    |> validate_required([:fantasy_league_name, :year, :division])
  end

  def by_league(query, league_id) do
    from(t in query, where: t.fantasy_league_id == ^league_id)
  end
end
