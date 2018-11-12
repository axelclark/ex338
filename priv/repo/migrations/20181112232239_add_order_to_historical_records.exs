defmodule Ex338.Repo.Migrations.AddOrderToHistoricalRecords do
  use Ecto.Migration

  def change do
    alter table("historical_records") do
      add :order, :float
    end
  end
end
