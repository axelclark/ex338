defmodule Ex338.Repo.Migrations.DropCoherenceRememberablesTable do
  use Ecto.Migration

  def up do
    drop(table(:rememberables))
  end

  def down do
    create table(:rememberables) do
      add(:series_hash, :string)
      add(:token_hash, :string)
      add(:token_created_at, :utc_datetime)
      add(:user_id, references(:users, on_delete: :delete_all))

      timestamps()
    end

    create(index(:rememberables, [:user_id]))
    create(index(:rememberables, [:series_hash]))
    create(index(:rememberables, [:token_hash]))
    create(unique_index(:rememberables, [:user_id, :series_hash, :token_hash]))
  end
end
