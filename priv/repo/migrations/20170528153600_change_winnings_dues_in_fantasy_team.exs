defmodule Ex338.Repo.Migrations.ChangeWinningsDuesInFantasyTeam do
  use Ecto.Migration

  def up do
    alter table(:fantasy_teams) do
      modify :dues_paid, :float, default: 0
      modify :winnings_received, :float, default: 0
    end
  end

  def down do
    alter table(:fantasy_teams) do
      modify :dues_paid, :decimal, default: 0
      modify :winnings_received, :decimal, default: 0
    end
  end
end
