defmodule Ex338.Repo.Migrations.CreateFantasyLeagueChampionship do
  use Ecto.Migration

  def change do
    create table(:fantasy_league_championships) do
      add(:fantasy_league_id, references(:fantasy_leagues, on_delete: :nothing))
      add(:championship_id, references(:championships, on_delete: :nothing))

      timestamps()
    end

    create(index(:fantasy_league_championships, [:fantasy_league_id]))
    create(index(:fantasy_league_championships, [:championship_id]))
  end
end
