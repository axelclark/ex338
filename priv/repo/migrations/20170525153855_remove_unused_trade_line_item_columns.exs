defmodule Ex338.Repo.Migrations.RemoveUnusedTradeLineItemColumns do
  use Ecto.Migration

  def up do
    drop index(:trade_line_items, [:fantasy_team_id])

    alter table(:trade_line_items) do
      remove :action
      remove :fantasy_team_id
    end
  end

  def down do
    alter table(:trade_line_items) do
      add :action, :string
      add :fantasy_team_id, references(:fantasy_teams, on_delete: :nothing)
    end

    create index(:trade_line_items, [:fantasy_team_id])
  end
end
