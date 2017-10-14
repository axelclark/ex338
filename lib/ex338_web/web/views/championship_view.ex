defmodule Ex338WebWeb.ChampionshipView do
  use Ex338Web, :view

  def get_team_name(%{fantasy_player: %{roster_positions: [position]}}) do
    position.fantasy_team.team_name
  end

  def get_team_name(_) do
    "-"
  end

  def filter_category(championships, category) do
    Enum.filter(championships, &(&1.category) == category)
  end

  def show_create_slots(
    %{admin: true}, %{category: "event", championship_slots: []}) do
     true
  end

  def show_create_slots(_user, _championship) do
    false
  end

  def show_create_picks(
    %{admin: true}, %{in_season_draft: true, in_season_draft_picks: []}) do
     true
  end

  def show_create_picks(_user, _championship) do
    false
  end
end
