defmodule Ex338Web.ViewHelpers do
  @moduledoc false
  alias Ex338.{
    FantasyTeams.FantasyTeam,
    Accounts.User,
    InSeasonDraftPicks.InSeasonDraftPick,
    FantasyPlayers.FantasyPlayer,
    FantasyPlayers.SportsLeague
  }

  alias Ex338Web.Router.Helpers, as: Routes
  import Calendar.Strftime
  import Phoenix.HTML, only: [sigil_E: 2]
  import Phoenix.HTML.Link, only: [link: 2]

  def admin_edit_path(resource) do
    # ExAdmin.Utils.admin_resource_path(resource, :edit)
  end

  def display_future_pick(%{round: round, original_team: original_team}) do
    "#{original_team.team_name}'s round #{round} pick in next year's draft"
  end

  def fantasy_team_link(conn, team) do
    link(team.team_name,
      to: Routes.fantasy_team_path(conn, :show, team.id)
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
    |> convert_to_pst
    |> strftime!("%b %e, %Y")
  end

  def short_datetime_pst(date) do
    date
    |> convert_to_pst
    |> strftime!("%b %e, %l:%M %p")
  end

  def sports_abbrevs(players_collection) do
    players_collection
    |> Enum.map(& &1.sports_league.abbrev)
    |> Enum.uniq()
  end

  def transaction_deadline_icon(%{waivers_closed?: true, trades_closed?: true}) do
    ~E"""
    <ion-icon name="lock"></ion-icon>
    """
  end

  def transaction_deadline_icon(%{waivers_closed?: true, trades_closed?: false}) do
    ~E"""
    <ion-icon name="swap"></ion-icon>
    """
  end

  def transaction_deadline_icon(%{waivers_closed?: false, trades_closed?: false}), do: ""

  def transaction_deadline_icon(_), do: ""

  ## Helpers

  defp convert_to_pst(%NaiveDateTime{} = date) do
    date
    |> DateTime.from_naive!("Etc/UTC")
    |> Calendar.DateTime.shift_zone!("America/Los_Angeles")
  end

  defp convert_to_pst(%DateTime{} = date) do
    Calendar.DateTime.shift_zone!(date, "America/Los_Angeles")
  end

  ## Implementations

  ## format_players_for_select

  defp format_player_select(%FantasyPlayer{
         player_name: name,
         id: id,
         sports_league: %SportsLeague{abbrev: abbrev}
       }) do
    [key: "#{name}, #{abbrev}", value: id]
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
end
