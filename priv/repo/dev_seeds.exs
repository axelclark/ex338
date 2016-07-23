# Script for populating the database. You can run it as:
#
#     mix run priv/repo/dev_seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ex338.Repo.insert!(%Ex338.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# 
# To substitue hidden characters in VIM %s/<ctr>v<ctrl>m/\r/g

alias Ex338.{RosterPosition, RosterTransaction, TransactionLineItem, Repo, 
             DraftPick}

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
  
  def store_draft_picks(row) do
    changeset = DraftPick.changeset(%DraftPick{}, row)
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

File.stream!("priv/repo/csv_seed_data/draft_picks.csv")
  |> Stream.drop(1)
  |> CSV.decode(headers: [:draft_position, :fantasy_league_id, :fantasy_team_id])
  |> Enum.each(&Ex338.DevSeeds.store_draft_picks/1)
