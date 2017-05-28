defmodule Ex338.Repo.Migrations.AddWinningsAdjToFantasyTeam do
  use Ecto.Migration

  def change do
    alter table(:fantasy_teams) do
      add :winnings_adj, :float, default: 0
    end
  end
end
