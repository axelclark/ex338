defmodule Ex338.Repo.Migrations.CreateWaiver do
  use Ecto.Migration

  def change do
    create table(:waivers) do
      add :status, :string
      add :fantasy_team_id, references(:fantasy_teams, on_delete: :nothing)
      add :add_fantasy_player_id, references(:fantasy_players, on_delete: :nothing)
      add :drop_fantasy_player_id, references(:fantasy_players, on_delete: :nothing)

      timestamps()
    end
    create index(:waivers, [:fantasy_team_id])
    create index(:waivers, [:add_fantasy_player_id])
    create index(:waivers, [:drop_fantasy_player_id])

  end
end
