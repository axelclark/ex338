defmodule Ex338.Repo.Migrations.AddWinningsDuesToFantasyTeam do
  use Ecto.Migration

  def change do
    alter table(:fantasy_teams) do
      add :dues_paid, :decimal, default: 0
      add :winnings_received, :decimal, default: 0
    end
  end
end
