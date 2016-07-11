defmodule Ex338.ExAdmin.RosterTransaction do
  @moduledoc false

  use ExAdmin.Register

  register_resource Ex338.RosterTransaction do

    form roster_transaction do
      inputs do
        input roster_transaction, :category, 
                                  collection: Ex338.RosterTransaction.categories
        input roster_transaction, :addtitional_terms
        input roster_transaction, :roster_transaction_on
      end
    end
  end
end
