defmodule Ex338.Repo.Migrations.AddGainingLosingTeamsToTradeLineItem do
  use Ecto.Migration

  def change do
    alter table(:trade_line_items) do
      add :gaining_team_id, references(:fantasy_teams, on_delete: :nothing)
      add :losing_team_id, references(:fantasy_teams, on_delete: :nothing)
    end
    create index(:trade_line_items, [:losing_team_id])
    create index(:trade_line_items, [:gaining_team_id])

  end
end
