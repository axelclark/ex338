defmodule Ex338.Repo.Migrations.AddYearToChampionship do
  use Ecto.Migration

  def change do
    alter table(:championships) do
      add :year, :integer, default: 2017
    end
  end
end
