defmodule Ex338.Trade.Store do
  @moduledoc false

  use Ex338.Web, :model

  alias Ex338.{Trade, Repo, Trade.Admin, RosterPosition}

  def all_for_league(league_id) do
    Trade
    |> Trade.by_league(league_id)
    |> Trade.preload_assocs
    |> Trade.newest_first
    |> Repo.all
  end

  def find!(id) do
    Trade
    |> Trade.preload_assocs
    |> Repo.get!(id)
  end

  def process_trade(trade_id, %{"status" => "Approved"} = params) do
    trade = find!(trade_id)

    case get_pos_from_trade(trade) do
      :error ->
        {:error, "One or more positions not found"}
      positions ->
        trade
        |> Admin.process_approved_trade(params, positions)
        |> Repo.transaction
    end
  end

  defp get_pos_from_trade(%{trade_line_items: line_items}) do
    positions = Enum.map(line_items, &query_pos_id/1)

    case Enum.any?(positions, &(&1 == nil)) do
      true -> :error
      false -> positions
    end
  end

  defp query_pos_id(item) do
    clause =
      %{
        fantasy_player_id: item.fantasy_player_id,
        fantasy_team_id: item.losing_team_id,
        status: "active"
      }

    RosterPosition.Store.get_by(clause)
  end
end
