defmodule Ex338.Repo.Migrations.CreateInjuredReserve do
  use Ecto.Migration

  def change do
    create table(:injured_reserves) do
      add :status, :string
      add :fantasy_team_id, references(:fantasy_teams, on_delete: :nothing)
      add :add_player_id, references(:fantasy_players, on_delete: :nothing)
      add :remove_player_id, references(:fantasy_players, on_delete: :nothing)
      add :replacement_player_id, references(:fantasy_players, on_delete: :nothing)

      timestamps()
    end
    create index(:injured_reserves, [:fantasy_team_id])
    create index(:injured_reserves, [:add_player_id])
    create index(:injured_reserves, [:remove_player_id])
    create index(:injured_reserves, [:replacement_player_id])

  end
end
