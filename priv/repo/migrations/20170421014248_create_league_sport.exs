defmodule Ex338.Repo.Migrations.CreateLeagueSport do
  use Ecto.Migration

  def change do
    create table(:league_sports) do
      add :fantasy_league_id, references(:fantasy_leagues, on_delete: :nothing)
      add :sports_league_id, references(:sports_leagues, on_delete: :nothing)

      timestamps()
    end
    create index(:league_sports, [:fantasy_league_id])
    create index(:league_sports, [:sports_league_id])

  end
end
