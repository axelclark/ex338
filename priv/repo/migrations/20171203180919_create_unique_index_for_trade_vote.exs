defmodule Ex338.Repo.Migrations.CreateUniqueIndexForTradeVote do
  use Ecto.Migration

  def up do
    create unique_index(:trade_votes, [:trade_id, :fantasy_team_id])
  end

  def down do
    drop unique_index(:trade_votes, [:trade_id, :fantasy_team_id])
  end
end
