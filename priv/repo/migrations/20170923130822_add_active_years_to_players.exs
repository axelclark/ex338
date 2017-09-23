defmodule Ex338.Repo.Migrations.AddActiveYearsToPlayers do
  use Ecto.Migration

  def change do
    alter table(:fantasy_players) do
      add :start_year, :integer, default: 2017
      add :end_year, :integer
    end
  end
end
