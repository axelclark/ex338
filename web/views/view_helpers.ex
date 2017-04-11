defmodule Ex338.ViewHelpers do
  alias Ex338.{FantasyTeam, User, DraftPick, InSeasonDraftPick}
  import Calendar.Strftime

  def format_players_for_select(players) do
    Enum.map(players, &(format_select(&1)))
  end

  def owner?(%User{id: id}, %FantasyTeam{owners: owners}) do
    owners
    |> Enum.any?(&(&1.user_id == id))
  end

  def owner?(current_user, %InSeasonDraftPick{} = draft_pick) do
    owners = draft_pick.draft_pick_asset.fantasy_team.owners
    Enum.any?(owners, &(&1.user_id == current_user.id))
  end

  def owner?(current_user, %DraftPick{} = draft_pick) do
    owners = draft_pick.fantasy_team.owners
    Enum.any?(owners, &(&1.user_id == current_user.id))
  end

  def pretty_date(date) do
    "#{pretty_month(date.month)} #{date.day}, #{date.year}"
  end

  def short_date(date) do
    date
    |> Ecto.DateTime.to_erl
    |> strftime!("%b %e, %Y")
  end

  def short_datetime_pst(%NaiveDateTime{} = date) do
    date
    |> DateTime.from_naive!("Etc/UTC")
    |> Calendar.DateTime.shift_zone!("America/Los_Angeles")
    |> strftime!("%b %e, %l:%M %p")
  end

  def short_datetime_pst(date) do
    date
    |> Ecto.DateTime.to_erl
    |> Calendar.DateTime.from_erl!("UTC")
    |> Calendar.DateTime.shift_zone!("America/Los_Angeles")
    |> strftime!("%b %e, %l:%M %p")
  end

  def sports_abbrevs(players_collection) do
    players_collection
    |> Enum.map(&(&1.league_abbrev))
    |> Enum.uniq
  end

  defp format_select(%{player_name: name, league_abbrev: abbrev, id: id}) do
    {"#{name}, #{abbrev}", id}
  end

  defp pretty_month(1),  do: "January"
  defp pretty_month(2),  do: "February"
  defp pretty_month(3),  do: "March"
  defp pretty_month(4),  do: "April"
  defp pretty_month(5),  do: "May"
  defp pretty_month(6),  do: "June"
  defp pretty_month(7),  do: "July"
  defp pretty_month(8),  do: "August"
  defp pretty_month(9),  do: "September"
  defp pretty_month(10), do: "October"
  defp pretty_month(11), do: "November"
  defp pretty_month(12), do: "December"
end
