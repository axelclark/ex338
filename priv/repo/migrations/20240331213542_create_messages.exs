defmodule Ex338.Repo.Migrations.CreateMessages do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text, null: false
      add :user_id, references(:users, on_delete: :delete_all)
      add :chat_id, references(:chats, on_delete: :delete_all)

      timestamps()
    end

    create index(:messages, [:user_id])
    create index(:messages, [:chat_id])
  end
end
