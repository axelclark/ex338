defmodule Ex338.InjuredReserves do
  @moduledoc """
  An interface to InjuredReseve
  """

  alias Ex338.{InjuredReserves.InjuredReserve, Repo, RosterPosition, InjuredReserves.Admin}

  def get_ir!(id) do
    InjuredReserve
    |> InjuredReserve.preload_assocs()
    |> Repo.get!(id)
  end

  def list_irs_for_league(league_id) do
    InjuredReserve
    |> InjuredReserve.by_league(league_id)
    |> InjuredReserve.preload_assocs()
    |> Repo.all()
  end

  def process_ir(ir_id, attrs) do
    ir = get_ir!(ir_id)

    case get_pos_from_ir(ir) do
      :error ->
        {:error, "Check IR is valid"}

      {_, %{ir: nil}} ->
        {:error, "RosterPosition for IR not found"}

      {_, %{replacement: nil}} ->
        {:error, "RosterPosition for IR not found"}

      {tagged_ir, positions} ->
        tagged_ir
        |> Admin.process_ir(attrs, positions)
        |> Repo.transaction()
    end
  end

  defp get_pos_from_ir(
         %{
           add_player_id: player_id,
           fantasy_team_id: team_id,
           remove_player_id: nil
         } = ir
       ) do
    ir_position = query_position(player_id, team_id, "active")

    {{:add, ir}, %{ir: ir_position, replacement: :none}}
  end

  defp get_pos_from_ir(
         %{
           add_player_id: nil,
           fantasy_team_id: team_id,
           remove_player_id: player_id,
           replacement_player_id: replacement_player_id
         } = ir
       ) do
    ir_position = query_position(player_id, team_id, "injured_reserve")
    replacement_pos = query_position(replacement_player_id, team_id, "active")

    {{:remove, ir}, %{ir: ir_position, replacement: replacement_pos}}
  end

  defp query_position(player_id, team_id, status) do
    clause = %{
      fantasy_player_id: player_id,
      fantasy_team_id: team_id,
      status: status
    }

    RosterPosition.Store.get_by(clause)
  end
end
