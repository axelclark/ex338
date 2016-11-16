defmodule Ex338.Repo.Migrations.CreateChampionshipResult do
  use Ecto.Migration

  def change do
    create table(:championship_results) do
      add :rank, :integer
      add :points, :integer
      add :championship_id, references(:championships, on_delete: :nothing)
      add :fantasy_player_id, references(:fantasy_players, on_delete: :nothing)

      timestamps()
    end
    create index(:championship_results, [:championship_id])
    create index(:championship_results, [:fantasy_player_id])

  end
end
