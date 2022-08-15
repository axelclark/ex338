defmodule Ex338Web.ChampionshipView do
  use Ex338Web, :view

  import Ex338Web.FantasyTeamView, only: [display_autodraft_setting: 1]

  def get_team_name(%{fantasy_player: %{roster_positions: [position]}}) do
    position.fantasy_team.team_name
  end

  def get_team_name(_) do
    "-"
  end

  def filter_category(championships, category) do
    Enum.filter(championships, &(&1.category == category))
  end

  def display_drafted_at_or_pick_due_at(%{available_to_pick?: false, drafted_player_id: nil}) do
    "---"
  end

  def display_drafted_at_or_pick_due_at(
        %{available_to_pick?: true, drafted_player_id: nil} = assigns
      ) do
    if assigns.over_time? do
      ~H"""
      <div class="text-red-600">
        <%= short_time_secs_pst(assigns.pick_due_at) %>*
      </div>
      """
    else
      ~H"""
      <div class="text-gray-800">
        <%= short_time_secs_pst(assigns.pick_due_at) %>*
      </div>
      """
    end
  end

  def display_drafted_at_or_pick_due_at(%{drafted_at: nil}) do
    "---"
  end

  def display_drafted_at_or_pick_due_at(pick) do
    short_time_pst(pick.drafted_at)
  end

  def show_create_slots(%{admin: true}, %{category: "event", championship_slots: []}) do
    true
  end

  def show_create_slots(_user, _championship) do
    false
  end

  def show_create_picks(%{admin: true}, %{in_season_draft: true, in_season_draft_picks: []}) do
    true
  end

  def show_create_picks(_user, _championship) do
    false
  end
end
