defmodule Ex338.Repo.Migrations.CreateDraftPick do
  use Ecto.Migration

  def change do
    create table(:draft_picks) do
      add :draft_position, :decimal, precision: 5, scale: 2
      add :round, :integer
      add :fantasy_league_id, references(:fantasy_leagues, on_delete: :delete_all)
      add :fantasy_team_id, references(:fantasy_teams, on_delete: :nothing)
      add :fantasy_player_id, references(:fantasy_players, on_delete: :nothing)

      timestamps()
    end
    create index(:draft_picks, [:fantasy_league_id])
    create index(:draft_picks, [:fantasy_team_id])
    create index(:draft_picks, [:fantasy_player_id])

  end
end
