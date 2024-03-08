defmodule Ex338.Repo.Migrations.CreateUsersAuthTables do
  @moduledoc false
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS citext", ""

    alter table(:users) do
      modify :email, :citext, null: false
      add :confirmed_at, :naive_datetime
    end

    create table(:users_tokens) do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:users_tokens, [:user_id])
    create unique_index(:users_tokens, [:context, :token])
  end

  def down do
    drop index(:users_tokens, [:context, :token])
    drop index(:users_tokens, [:user_id])

    drop table(:users_tokens)

    alter table(:users) do
      remove :confirmed_at
      modify :email, :string, null: false
    end
  end
end
