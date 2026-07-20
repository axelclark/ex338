defmodule Ex338.Repo.Migrations.AddPrivateToFantasyLeagues do
  use Ecto.Migration

  def change do
    alter table(:fantasy_leagues) do
      add :private?, :boolean, default: false, null: false
    end
  end
end
