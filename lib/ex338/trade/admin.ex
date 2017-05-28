defmodule Ex338.Trade.Admin do
  @moduledoc """
  Returns an `Ecto.Multi` with actions to process an approved `Trade`.
  """

  alias Ecto.Multi
  alias Ex338.{Trade, RosterPosition}

  def process_approved_trade(trade, params, losing_positions) do
    Multi.new
    |> update_trade(trade, params)
    |> update_losing_positions(losing_positions)
    |> insert_gaining_positions(trade.trade_line_items)
  end

  defp update_trade(multi, trade, params) do
    Multi.update(multi, :trade, Trade.changeset(trade, params))
  end

  defp update_losing_positions(multi, losing_positions) do
    Enum.reduce losing_positions, multi, fn(position, multi) ->
      update_losing_position(multi, position)
    end
  end

  defp update_losing_position(multi, position) do
    multi_name = create_multi_name("losing_position_", position.id)
    params = %{"status" => "traded"}
    Multi.update(multi, multi_name, RosterPosition.changeset(position, params))
  end

  defp insert_gaining_positions(multi, line_items) do
    Enum.reduce line_items, multi, fn(line_item, multi) ->
      insert_gaining_position(multi, line_item)
    end
  end

  defp insert_gaining_position(multi, line_item) do
    team_id = line_item.gaining_team_id
    player_id = line_item.fantasy_player_id
    multi_name = create_multi_name("gaining_position_", player_id)
    params =
      %{
        "fantasy_team_id" => team_id,
        "fantasy_player_id" => player_id,
        "active_at" => Ecto.DateTime.utc(),
        "position" => "Unassigned",
        "status" => "active"
      }

    Multi.insert(
      multi,
      multi_name,
      RosterPosition.changeset(%RosterPosition{}, params)
    )
  end

  defp create_multi_name(name, integer) do
    String.to_atom("#{name}#{Integer.to_string(integer)}")
  end
end
