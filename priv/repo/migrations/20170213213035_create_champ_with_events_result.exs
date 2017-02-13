defmodule Ex338.Repo.Migrations.CreateChampWithEventsResult do
  use Ecto.Migration

  def change do
    create table(:champ_with_events_results) do
      add :rank, :integer
      add :points, :decimal
      add :winnings, :decimal
      add :fantasy_team_id, references(:fantasy_teams, on_delete: :nothing)
      add :championship_id, references(:championships, on_delete: :nothing)

      timestamps()
    end
    create index(:champ_with_events_results, [:fantasy_team_id])
    create index(:champ_with_events_results, [:championship_id])

  end
end
