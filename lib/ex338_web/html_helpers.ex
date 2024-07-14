defmodule Ex338Web.HTMLHelpers do
  @moduledoc false
  use Phoenix.VerifiedRoutes, endpoint: Ex338Web.Endpoint, router: Ex338Web.Router

  import Phoenix.Component
  import Phoenix.HTML.Link, only: [link: 2]

  alias Ex338.Accounts.User
  alias Ex338.FantasyPlayers.FantasyPlayer
  alias Ex338.FantasyPlayers.SportsLeague
  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.InSeasonDraftPicks.InSeasonDraftPick

  def admin?(%User{admin: true}), do: true
  def admin?(_current_user), do: false

  def display_future_pick(%{round: round, original_team: original_team}) do
    "#{original_team.team_name}'s round #{round} pick in next year's draft"
  end

  def fantasy_team_link(_conn, team) do
    link(team.team_name,
      to: ~p"/fantasy_teams/#{team.id}"
    )
  end

  def format_whole_dollars(number) when is_float(number) do
    number = Decimal.from_float(number)
    Number.Currency.number_to_currency(number, precision: 0)
  end

  def format_whole_dollars(number) when is_integer(number) do
    Number.Currency.number_to_currency(number, precision: 0)
  end

  def format_future_picks_for_select(future_picks) do
    Enum.map(future_picks, &format_future_pick_select(&1))
  end

  def format_players_for_select(players) do
    Enum.map(players, &format_player_select(&1))
  end

  def format_teams_for_select(players) do
    Enum.map(players, &format_team_select(&1))
  end

  def maybe_fetch_current_user_id(nil), do: nil

  def maybe_fetch_current_user_id(current_user), do: current_user.id

  def owner?(nil, _), do: false

  def owner?(%User{id: current_user_id}, %FantasyTeam{owners: owners}) do
    Enum.any?(owners, &(&1.user_id == current_user_id))
  end

  def owner?(%User{id: current_user_id}, %InSeasonDraftPick{} = draft_pick) do
    owners = draft_pick.draft_pick_asset.fantasy_team.owners
    Enum.any?(owners, &(&1.user_id == current_user_id))
  end

  def owner?(%User{id: current_user_id}, asset) do
    owners = asset.fantasy_team.owners
    Enum.any?(owners, &(&1.user_id == current_user_id))
  end

  def short_date_pst(date) do
    date
    |> convert_to_pst()
    |> Calendar.strftime("%b %d, %Y")
  end

  def short_datetime_pst(date) do
    date
    |> convert_to_pst()
    |> Calendar.strftime("%b %d, %I:%M %p")
  end

  def short_time_pst(date) do
    date
    |> convert_to_pst()
    |> Calendar.strftime("%I:%M %p")
  end

  def short_time_secs_pst(date) do
    date
    |> convert_to_pst()
    |> Calendar.strftime("%I:%M:%S %p")
  end

  def sports_abbrevs(players_collection) do
    players_collection
    |> Enum.map(&format_sport_select_from_player/1)
    |> Enum.uniq()
  end

  def transaction_deadline_icon(%{waivers_closed?: true, trades_closed?: true} = assigns) do
    ~H"""
    <svg
      class="m-auto"
      fill="none"
      stroke-linecap="round"
      stroke-linejoin="round"
      stroke-width="2"
      viewBox="0 0 24 24"
      stroke="currentColor"
    >
      <path d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z">
      </path>
    </svg>
    """
  end

  def transaction_deadline_icon(%{waivers_closed?: true, trades_closed?: false} = assigns) do
    ~H"""
    <svg
      fill="none"
      stroke-linecap="round"
      stroke-linejoin="round"
      stroke-width="2"
      viewBox="0 0 24 24"
      stroke="currentColor"
    >
      <path d="M8 7h12m0 0l-4-4m4 4l-4 4m0 6H4m0 0l4 4m-4-4l4-4"></path>
    </svg>
    """
  end

  def transaction_deadline_icon(%{waivers_closed?: false, trades_closed?: false}), do: ""

  def transaction_deadline_icon(_), do: ""

  ## Helpers

  defp convert_to_pst(%NaiveDateTime{} = date) do
    date
    |> DateTime.from_naive!("Etc/UTC")
    |> DateTime.shift_zone!("America/Los_Angeles")
  end

  defp convert_to_pst(%DateTime{} = date) do
    DateTime.shift_zone!(date, "America/Los_Angeles")
  end

  ## Implementations

  ## format_players_for_select

  defp format_player_select(%FantasyPlayer{
         player_name: name,
         id: id,
         sports_league: %SportsLeague{abbrev: abbrev}
       }) do
    [key: "#{name}, #{abbrev}", value: id, class: "#{abbrev}"]
  end

  defp format_player_select(%{
         player_name: name,
         league_abbrev: abbrev,
         id: id,
         fantasy_team_id: fantasy_team_id
       }) do
    [key: "#{name}, #{abbrev}", value: id, class: "fantasy-team-#{fantasy_team_id}"]
  end

  defp format_team_select(%{team_name: name, id: id}) do
    [key: "#{name}", value: id, class: "fantasy-team-#{id}"]
  end

  defp format_future_pick_select(future_pick) do
    %{current_team: current_team, id: id, round: round} = future_pick

    [
      key: "#{current_team.team_name}: round #{round}",
      value: id,
      class: "fantasy-team-#{current_team.id}"
    ]
  end

  defp format_sport_select_from_player(player) do
    [key: player.sports_league.league_name, value: player.sports_league.abbrev]
  end
end
