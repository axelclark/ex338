defmodule Ex338.Repo.Migrations.AddIsKeeperToDraftPicks do
  use Ecto.Migration

  def change do
    alter table(:draft_picks) do
      add :is_keeper, :boolean, default: false, null: false
    end
  end
end
