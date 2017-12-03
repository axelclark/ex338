defmodule Ex338.Repo.Migrations.CreateTradeVotes do
  use Ecto.Migration

  def change do
    create table(:trade_votes) do
      add :approve, :boolean, default: true, null: false
      add :trade_id, references(:trades, on_delete: :delete_all)
      add :fantasy_team_id, references(:fantasy_teams, on_delete: :nilify_all)
      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end

    create index(:trade_votes, [:trade_id])
    create index(:trade_votes, [:fantasy_team_id])
    create index(:trade_votes, [:user_id])
  end
end
