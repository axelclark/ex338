defmodule Ex338.Repo.Migrations.AddNameToFantasyLeague do
  use Ecto.Migration

  def up do
    alter table(:fantasy_leagues) do
      add :fantasy_league_name, :string
    end
  end

  def down do
    alter table(:fantasy_leagues) do
      remove :fantasy_league_name
    end
  end
end
