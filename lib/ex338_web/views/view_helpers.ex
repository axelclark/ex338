defmodule Ex338Web.ViewHelpers do
  @moduledoc false
  alias Ex338.{FantasyTeam, User, InSeasonDraftPick}
  import Calendar.Strftime

  def admin_edit_path(resource) do
    ExAdmin.Utils.admin_resource_path(resource, :edit)
  end

  def format_players_for_select(players) do
    Enum.map(players, &(format_player_select(&1)))
  end

  def format_teams_for_select(players) do
    Enum.map(players, &(format_team_select(&1)))
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
    |> Enum.map(&(&1.league_abbrev))
    |> Enum.uniq
  end

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

  defp format_player_select(%{player_name: name, league_abbrev: abbrev, id: id}) do
    {"#{name}, #{abbrev}", id}
  end

  defp format_team_select(%{team_name: name, id: id}) do
    {"#{name}", id}
  end
end
