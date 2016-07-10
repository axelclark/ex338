defmodule Ex338.Repo.Migrations.CreateRosterPosition do
  use Ecto.Migration

  def change do
    create table(:roster_positions) do
      add :position, :string
      add :fantasy_team_id, references(:fantasy_teams, on_delete: :delete_all)
      add :fantasy_player_id, references(:fantasy_players, 
                                         on_delete: :delete_all)

      timestamps()
    end
    create index(:roster_positions, [:fantasy_team_id])
    create index(:roster_positions, [:fantasy_player_id])

  end
end
