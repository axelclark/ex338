defmodule Ex338Web.Api.V1.InjuredReserveJSON do
  def index(%{injured_reserves: injured_reserves}) do
    %{injured_reserves: Enum.map(injured_reserves, &ir_data/1)}
  end

  defp ir_data(ir) do
    %{
      id: ir.id,
      status: ir.status,
      fantasy_team: %{
        id: ir.fantasy_team.id,
        team_name: ir.fantasy_team.team_name
      },
      injured_player: player_data(ir.injured_player),
      replacement_player: player_data(ir.replacement_player),
      inserted_at: ir.inserted_at
    }
  end

  defp player_data(%{id: id} = player) do
    %{id: id, player_name: player.player_name}
  end

  defp player_data(_), do: nil
end
