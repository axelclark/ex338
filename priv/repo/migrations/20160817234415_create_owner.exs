defmodule Ex338.Repo.Migrations.CreateOwner do
  use Ecto.Migration

  def change do
    create table(:owners) do
      add :fantasy_team_id, references(:fantasy_teams, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
    create index(:owners, [:fantasy_team_id])
    create index(:owners, [:user_id])

  end
end
