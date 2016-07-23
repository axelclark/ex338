defmodule Ex338.ExAdmin.TransactionLineItem do
  @moduledoc false

  use ExAdmin.Register

  register_resource Ex338.TransactionLineItem do

    form transaction_line_item do
      inputs do
        input transaction_line_item, :roster_transaction,
                                     collection: Ex338.RosterTransaction.all,
                                     fields: [:category, :id]
        input transaction_line_item, :fantasy_team,
                                     collection: Ex338.FantasyTeam.all
        input transaction_line_item, :action,
                                     collection: Ex338.TransactionLineItem.actions
        input transaction_line_item, :fantasy_player,
                                     collection: Ex338.FantasyPlayer.all
      end
    end
  end
end
