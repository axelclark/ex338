defmodule Ex338.Repo.Migrations.AddOverallIdToChampionship do
  use Ecto.Migration

  def change do
    alter table(:championships) do
      add :overall_id, references(:championships)
    end
  end
end
