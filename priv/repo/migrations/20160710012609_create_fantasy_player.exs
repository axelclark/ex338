defmodule Ex338.Repo.Migrations.CreateFantasyPlayer do
  use Ecto.Migration

  def change do
    create table(:fantasy_players) do
      add :player_name, :string 
      add :sports_league_id, references(:sports_leagues, on_delete: :delete_all)

      timestamps()
    end
    create index(:fantasy_players, [:sports_league_id])

  end
end
