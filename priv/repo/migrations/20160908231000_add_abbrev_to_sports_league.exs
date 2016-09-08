defmodule Ex338.Repo.Migrations.AddAbbrevToSportsLeague do
  use Ecto.Migration

  def change do
    alter table(:sports_leagues) do
      add :abbrev, :string
    end
  end
end
