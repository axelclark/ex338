defmodule Ex338Web.Api.V1.FantasyTeamJSON do
  def show(%{fantasy_team: team}) do
    %{fantasy_team: team_data(team)}
  end

  defp team_data(team) do
    %{
      id: team.id,
      team_name: team.team_name,
      waiver_position: team.waiver_position,
      points: Map.get(team, :points),
      winnings: Map.get(team, :winnings),
      fantasy_league: %{
        id: team.fantasy_league.id,
        fantasy_league_name: team.fantasy_league.fantasy_league_name
      },
      owners: Enum.map(team.owners, &owner_data/1),
      roster_positions: Enum.map(team.roster_positions, &roster_position_data/1)
    }
  end

  defp owner_data(owner) do
    %{
      id: owner.id,
      user: %{
        id: owner.user.id,
        name: owner.user.name
      }
    }
  end

  defp roster_position_data(%{id: id} = position) do
    %{
      id: id,
      position: position.position,
      status: position.status,
      fantasy_player: player_data(position.fantasy_player)
    }
  end

  defp roster_position_data(position) do
    %{
      id: nil,
      position: position.position,
      status: nil,
      fantasy_player: player_data(Map.get(position, :fantasy_player))
    }
  end

  defp player_data(%{id: id} = player) do
    %{
      id: id,
      player_name: player.player_name,
      sports_league: player.sports_league.abbrev
    }
  end

  defp player_data(_), do: nil
end
