defmodule Ex338.Repo.Migrations.CreateChats do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:chats) do
      add :room_name, :string, null: false
      timestamps()
    end

    create unique_index(:chats, [:room_name])
  end
end
