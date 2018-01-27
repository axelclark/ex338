defmodule Ex338.Repo.Migrations.CreateDraftQueues do
  use Ecto.Migration

  def change do
    create table(:draft_queues) do
      add :order, :integer, null: false
      add :fantasy_team_id, references(:fantasy_teams, on_delete: :delete_all), null: false
      add :fantasy_player_id, references(:fantasy_players, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:draft_queues, [:fantasy_team_id])
    create index(:draft_queues, [:fantasy_player_id])
  end
end
