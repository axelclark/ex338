defmodule Ex338Web.Api.V1.WaiverJSON do
  def index(%{waivers: waivers}) do
    %{waivers: Enum.map(waivers, &waiver_data/1)}
  end

  defp waiver_data(waiver) do
    %{
      id: waiver.id,
      status: waiver.status,
      process_at: waiver.process_at,
      fantasy_team: %{
        id: waiver.fantasy_team.id,
        team_name: waiver.fantasy_team.team_name
      },
      add_fantasy_player: player_data(waiver.add_fantasy_player),
      drop_fantasy_player: player_data(waiver.drop_fantasy_player),
      inserted_at: waiver.inserted_at
    }
  end

  defp player_data(%{id: id} = player) do
    %{id: id, player_name: player.player_name}
  end

  defp player_data(_), do: nil
end
