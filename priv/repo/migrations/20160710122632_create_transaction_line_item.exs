defmodule Ex338.Repo.Migrations.CreateTransactionLineItem do
  use Ecto.Migration

  def change do
    create table(:transaction_line_items) do
      add :action, :string
      add :roster_transaction_id, references(:roster_transactions, 
                                             on_delete: :delete_all)
      add :fantasy_team_id, references(:fantasy_teams, on_delete: :nothing)
      add :fantasy_player_id, references(:fantasy_players, on_delete: :nothing)

      timestamps()
    end
    create index(:transaction_line_items, [:roster_transaction_id])
    create index(:transaction_line_items, [:fantasy_team_id])
    create index(:transaction_line_items, [:fantasy_player_id])

  end
end
