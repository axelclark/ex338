defmodule Ex338.ChampionshipView do
  use Ex338.Web, :view

  def get_team_name(%{fantasy_player: %{roster_positions: [position]}}) do
    position.fantasy_team.team_name
  end

  def get_team_name(_) do
    "-"
  end
end
