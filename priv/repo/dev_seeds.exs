alias Ex338.{RosterPosition, RosterTransaction, TransactionLineItem, Repo}

defmodule Ex338.DevSeeds do
  def store_roster_positions(row) do
    changeset = RosterPosition.changeset(%RosterPosition{}, row)
    Repo.insert!(changeset)
  end
  
  def store_roster_transactions(row) do
    changeset = RosterTransaction.changeset(%RosterTransaction{}, row)
    Repo.insert!(changeset)
  end
  
  def store_transaction_line_items(row) do
    changeset = TransactionLineItem.changeset(%TransactionLineItem{}, row)
    Repo.insert!(changeset)
  end
end

File.stream!("priv/repo/csv_seed_data/roster_positions.csv")
  |> CSV.decode(headers: [:fantasy_team_id, :team_name, 
                          :fantasy_player_id, :player_name, :position])
  |> Enum.each(&Ex338.DevSeeds.store_roster_positions/1)

File.stream!("priv/repo/csv_seed_data/roster_transactions.csv")
  |> CSV.decode(headers: [:category, :roster_transaction_on])
  |> Enum.each(&Ex338.DevSeeds.store_roster_transactions/1)

File.stream!("priv/repo/csv_seed_data/transaction_line_items.csv")
  |> CSV.decode(headers: [:fantasy_team_id, :fantasy_player_id, :action, 
                          :roster_transaction_id])
  |> Enum.each(&Ex338.DevSeeds.store_transaction_line_items/1)
