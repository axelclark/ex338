defmodule Ex338.FantasyLeagues.FantasyLeague do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Ex338.FantasyTeams.FantasyTeam

  # A channel ID (C… for a channel, G… for a legacy private group) or a #name.
  # Catching a typo here beats finding out from a cancelled background job.
  @slack_channel_format ~r/^(#[a-z0-9._-]{1,80}|[CG][A-Z0-9]{8,})$/

  schema "fantasy_leagues" do
    field(:fantasy_league_name, :string)
    field(:year, :integer)
    field(:division, :string)
    field(:only_flex?, :boolean, default: false)
    field(:must_draft_each_sport?, :boolean, default: true)
    field(:championships_start_at, :utc_datetime)
    field(:championships_end_at, :utc_datetime)
    field(:navbar_display, FantasyLeagueNavbarDisplayEnum, default: "primary")
    field(:draft_method, FantasyLeagueDraftMethodEnum, default: "redraft")
    field(:max_draft_hours, :integer, default: 0)
    field(:max_flex_spots, :integer)
    field(:draft_picks_locked?, :boolean, default: false)
    field(:private?, :boolean, default: false)
    field(:slack_alerts_channel, :string)
    belongs_to(:sport_draft, Ex338.FantasyPlayers.SportsLeague)
    has_many(:fantasy_teams, FantasyTeam)
    has_many(:draft_picks, Ex338.DraftPicks.DraftPick)
    has_many(:league_sports, Ex338.FantasyLeagues.LeagueSport)

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
      :draft_picks_locked?,
      :fantasy_league_name,
      :max_draft_hours,
      :max_flex_spots,
      :must_draft_each_sport?,
      :navbar_display,
      :only_flex?,
      :private?,
      :slack_alerts_channel,
      :sport_draft_id,
      :year
    ])
    |> validate_required([:fantasy_league_name, :year, :division])
    |> update_change(:slack_alerts_channel, &normalize_slack_channel/1)
    |> validate_format(:slack_alerts_channel, @slack_channel_format,
      message: "must be a channel ID like C0123456789 or a name like #338-alerts"
    )
  end

  @doc """
  Builds a changeset for commish editing league with fantasy teams.
  """
  def commish_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [
      :championships_end_at,
      :championships_start_at,
      :division,
      :draft_method,
      :draft_picks_locked?,
      :fantasy_league_name,
      :max_draft_hours,
      :max_flex_spots,
      :must_draft_each_sport?,
      :navbar_display,
      :only_flex?,
      :private?,
      :slack_alerts_channel,
      :sport_draft_id,
      :year
    ])
    |> validate_required([:fantasy_league_name, :year, :division])
    |> update_change(:slack_alerts_channel, &normalize_slack_channel/1)
    |> validate_format(:slack_alerts_channel, @slack_channel_format,
      message: "must be a channel ID like C0123456789 or a name like #338-alerts"
    )
    |> cast_assoc(:fantasy_teams, with: &FantasyTeam.commish_changeset/2)
  end

  # Slack rejects channels with stray whitespace, so trim and treat blanks as unset.
  defp normalize_slack_channel(nil), do: nil

  defp normalize_slack_channel(channel) do
    case String.trim(channel) do
      "" -> nil
      trimmed -> trimmed
    end
  end

  def by_league(query, league_id) do
    from(t in query, where: t.fantasy_league_id == ^league_id)
  end

  def sort_by_division(query) do
    from(t in query, order_by: [asc: t.division])
  end

  def sort_by_draft_method(query) do
    from(t in query, order_by: [desc: t.draft_method])
  end

  def sort_most_recent(query) do
    from(t in query, order_by: [desc: t.year])
  end

  def sort_private_first(query) do
    from(t in query, order_by: [desc: t.private?])
  end
end
