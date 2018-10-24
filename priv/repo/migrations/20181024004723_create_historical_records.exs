defmodule Ex338.Repo.Migrations.CreateHistoricalRecords do
  use Ecto.Migration

  def change do
    create table(:historical_records) do
      add :description, :string
      add :record, :string
      add :team, :string
      add :year, :string
      add :archived, :boolean, default: false

      timestamps()
    end
  end
end
