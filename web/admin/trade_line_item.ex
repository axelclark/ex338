defmodule Ex338.ExAdmin.TradeLineItem do
  use ExAdmin.Register

  register_resource Ex338.TradeLineItem do

    index do
      selectable_column

      column :id
      column :trade, fields: [:id], label: "Trade Id"
      column :fantasy_team
      column :action
      column :fantasy_player
      actions
    end

    form trade_line_item do
      inputs do
        input trade_line_item, :trade, collection: Ex338.Trade.all,
                                       fields: [:id, :status]
        input trade_line_item, :fantasy_team, collection: Ex338.FantasyTeam.all
        input trade_line_item, :action,
                               collection: Ex338.TradeLineItem.action_options
        input trade_line_item, :fantasy_player,
                               collection: Ex338.FantasyPlayer.all
      end
    end

    show trade_line_item do
      attributes_table do
        row :trade, fields: [:id], label: "Trade Id"
        row :fantasy_team
        row :action
        row :fantasy_player
      end
    end
  end
end
