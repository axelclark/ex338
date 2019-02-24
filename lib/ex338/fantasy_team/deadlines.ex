defmodule Ex338.FantasyTeam.Deadlines do
  @moduledoc """
  Adds deadline booleans to roster positions
  """

  def add_for_league(teams) do
    Enum.map(teams, &add_for_team(&1))
  end

  def add_for_team(%{roster_positions: positions} = team) do
    positions = update_positions(positions)

    %{team | roster_positions: positions}
  end

  ## Implementations

  ## add_for_team

  defp update_positions(positions) do
    Enum.map(positions, &update_position/1)
  end

  defp update_position(
         %{fantasy_player: %{sports_league: %{championships: [overall]}}} = position
       ) do
    overall = Ex338.Championship.add_deadline_statuses(overall)

    update_championship(position, overall)
  end

  defp update_position(position), do: position

  defp update_championship(position, championship) do
    put_in(
      position,
      [
        Access.key(:fantasy_player),
        Access.key(:sports_league),
        Access.key(:championships),
        Access.at(0)
      ],
      championship
    )
  end
end
