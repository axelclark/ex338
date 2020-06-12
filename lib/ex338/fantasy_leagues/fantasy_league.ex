defmodule Ex338.FantasyLeagues.FantasyLeague do
  @moduledoc false

  use Ex338Web, :model

  schema "fantasy_leagues" do
    field(:fantasy_league_name, :string)
    field(:year, :integer)
    field(:division, :string)
    field(:championships_start_at, :utc_datetime)
    field(:championships_end_at, :utc_datetime)
    field(:navbar_display, FantasyLeagueNavbarDisplayEnum, default: "primary")
    field(:draft_method, FantasyLeagueDraftMethodEnum, default: "redraft")
    field(:max_draft_hours, :integer, default: 0)
    field(:max_flex_spots, :integer)
    belongs_to(:sport_draft, Ex338.SportsLeague)
    has_many(:fantasy_teams, Ex338.FantasyTeam)
    has_many(:draft_picks, Ex338.DraftPick)
    has_many(:league_sports, Ex338.LeagueSport)

    timestamps()
  end

  def leagues_by_status(query, status) do
    from(l in query, where: l.navbar_display == ^status)
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :championships_end_at,
      :championships_start_at,
      :division,
      :draft_method,
      :fantasy_league_name,
      :max_draft_hours,
      :max_flex_spots,
      :navbar_display,
      :sport_draft_id,
      :year
    ])
    |> validate_required([:fantasy_league_name, :year, :division])
  end

  def by_league(query, league_id) do
    from(t in query, where: t.fantasy_league_id == ^league_id)
  end

  def sort_most_recent(query) do
    from(t in query, order_by: [desc: t.year])
  end

  def sort_by_division(query) do
    from(t in query, order_by: [asc: t.division])
  end
end
