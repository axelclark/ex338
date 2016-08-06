defmodule Ex338.Repo.Migrations.CreateTradeLineItem do
  use Ecto.Migration

  def change do
    create table(:trade_line_items) do
      add :action, :string
      add :trade_id, references(:trades, on_delete: :delete_all)
      add :fantasy_team_id, references(:fantasy_teams, on_delete: :nothing)
      add :fantasy_player_id, references(:fantasy_players, on_delete: :nothing)

      timestamps()
    end
    create index(:trade_line_items, [:trade_id])
    create index(:trade_line_items, [:fantasy_team_id])
    create index(:trade_line_items, [:fantasy_player_id])

  end
end
