defmodule Ex338Web.Api.V1.TradeJSON do
  def index(%{trades: trades}) do
    %{trades: Enum.map(trades, &trade_data/1)}
  end

  defp trade_data(trade) do
    %{
      id: trade.id,
      status: trade.status,
      additional_terms: trade.additional_terms,
      yes_votes: trade.yes_votes,
      no_votes: trade.no_votes,
      trade_line_items: Enum.map(trade.trade_line_items, &line_item_data/1),
      inserted_at: trade.inserted_at
    }
  end

  defp line_item_data(item) do
    %{
      id: item.id,
      losing_team: %{id: item.losing_team.id, team_name: item.losing_team.team_name},
      gaining_team: %{id: item.gaining_team.id, team_name: item.gaining_team.team_name},
      fantasy_player: player_data(item.fantasy_player),
      future_pick: future_pick_data(item.future_pick)
    }
  end

  defp player_data(%{id: id} = player) do
    %{id: id, player_name: player.player_name}
  end

  defp player_data(_), do: nil

  defp future_pick_data(%{id: id} = pick) do
    %{
      id: id,
      round: pick.round,
      original_team: %{
        id: pick.original_team.id,
        team_name: pick.original_team.team_name
      }
    }
  end

  defp future_pick_data(_), do: nil
end
