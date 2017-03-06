defmodule Ex338.Repo.Migrations.AddProcessAtToWaiver do
  use Ecto.Migration

  def change do
    alter table(:waivers) do
      add :process_at, :utc_datetime
    end
  end
end
