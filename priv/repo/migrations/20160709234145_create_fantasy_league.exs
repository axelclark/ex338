defmodule Ex338.Repo.Migrations.CreateFantasyLeague do
  use Ecto.Migration

  def change do
    create table(:fantasy_leagues) do
      add :year, :integer
      add :division, :string

      timestamps()
    end

  end
end
