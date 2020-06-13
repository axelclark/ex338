defmodule Ex338.Trades.Admin do
  @moduledoc """
  Returns an `Ecto.Multi` with actions to process an approved `Trade`.
  """

  alias Ecto.Multi
  alias Ex338.{DraftPicks, Trades.Trade, RosterPositions.RosterPosition}

  def process_approved_trade(trade, params, losing_positions) do
    Multi.new()
    |> update_trade(trade, params)
    |> update_losing_positions(losing_positions)
    |> insert_gaining_positions(trade.trade_line_items)
    |> update_future_picks(trade.trade_line_items)
  end

  defp update_trade(multi, trade, params) do
    Multi.update(multi, :trade, Trade.changeset(trade, params))
  end

  defp update_losing_positions(multi, losing_positions) do
    Enum.reduce(losing_positions, multi, fn position, multi ->
      update_losing_position(multi, position)
    end)
  end

  defp update_losing_position(multi, position) do
    multi_name = create_multi_name("losing_position_", position.id)

    params = %{
      "status" => "traded",
      "released_at" => DateTime.utc_now()
    }

    Multi.update(multi, multi_name, RosterPosition.changeset(position, params))
  end

  defp insert_gaining_positions(multi, line_items) do
    Enum.reduce(line_items, multi, &insert_gaining_position/2)
  end

  defp insert_gaining_position(%{fantasy_player_id: nil}, multi), do: multi

  defp insert_gaining_position(line_item, multi) do
    team_id = line_item.gaining_team_id
    player_id = line_item.fantasy_player_id
    multi_name = create_multi_name("gaining_position_", player_id)

    params = %{
      "fantasy_team_id" => team_id,
      "fantasy_player_id" => player_id,
      "active_at" => DateTime.utc_now(),
      "acq_method" => "trade",
      "position" => "Unassigned",
      "status" => "active"
    }

    Multi.insert(
      multi,
      multi_name,
      RosterPosition.changeset(%RosterPosition{}, params)
    )
  end

  defp update_future_picks(multi, line_items) do
    Enum.reduce(line_items, multi, &update_future_pick/2)
  end

  defp update_future_pick(%{future_pick_id: nil}, multi), do: multi

  defp update_future_pick(line_item, multi) do
    future_pick_id = line_item.future_pick_id
    multi_name = create_multi_name("future_pick_", future_pick_id)

    params = %{
      "current_team_id" => line_item.gaining_team_id
    }

    Multi.update(
      multi,
      multi_name,
      DraftPicks.change_future_pick(line_item.future_pick, params)
    )
  end

  defp create_multi_name(name, integer) do
    String.to_atom("#{name}#{Integer.to_string(integer)}")
  end
end
