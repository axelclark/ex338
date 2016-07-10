defmodule Ex338.Repo.Migrations.CreateFantasyTeam do
  use Ecto.Migration

  def change do
    create table(:fantasy_teams) do
      add :team_name, :string, null: false
      add :waiver_position, :integer
      add :fantasy_league_id, references(:fantasy_leagues, on_delete: :nothing)

      timestamps()
    end
    create index(:fantasy_teams, [:fantasy_league_id])

  end
end
