defmodule Ex338.Repo.Migrations.AddUserAndTeamToTrade do
  use Ecto.Migration

  def change do
    alter table(:trades) do
      add :submitted_by_user_id, references(:users, on_delete: :nilify_all)
      add :submitted_by_team_id, references(:fantasy_teams, on_delete: :nilify_all)
    end
    create index(:trades, [:submitted_by_user_id])
    create index(:trades, [:submitted_by_team_id])

  end
end
