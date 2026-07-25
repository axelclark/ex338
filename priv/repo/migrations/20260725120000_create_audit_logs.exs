defmodule Ex338.Repo.Migrations.CreateAuditLogs do
  use Ecto.Migration

  def change do
    create table(:audit_logs) do
      add :user_id, references(:users, on_delete: :nilify_all)
      add :api_token_id, references(:users_tokens, on_delete: :nilify_all)
      add :fantasy_league_id, references(:fantasy_leagues, on_delete: :nilify_all)
      add :source, :string, null: false
      add :action, :string, null: false
      add :resource_type, :string
      add :resource_id, :bigint
      add :outcome, :string, null: false
      add :metadata, :map, null: false, default: %{}

      timestamps(updated_at: false, type: :utc_datetime)
    end

    create index(:audit_logs, [:user_id])
    create index(:audit_logs, [:api_token_id])
    create index(:audit_logs, [:fantasy_league_id])
    create index(:audit_logs, [:resource_type, :resource_id])
    create index(:audit_logs, [:inserted_at])
  end
end
