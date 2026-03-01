defmodule Ex338Web.Api.V1.FantasyPlayerJSON do
  def index(%{players_by_sport: players_by_sport}) do
    fantasy_players =
      Enum.flat_map(players_by_sport, fn {sport, players} ->
        Enum.map(players, &player_data(&1, sport))
      end)

    %{fantasy_players: fantasy_players}
  end

  defp player_data(player, sport) do
    %{
      id: player.id,
      player_name: player.player_name,
      sports_league: sport.abbrev,
      roster_positions:
        Enum.map(player.roster_positions, fn pos ->
          %{
            fantasy_team: %{
              id: pos.fantasy_team.id,
              team_name: pos.fantasy_team.team_name
            },
            status: pos.status
          }
        end)
    }
  end
end
