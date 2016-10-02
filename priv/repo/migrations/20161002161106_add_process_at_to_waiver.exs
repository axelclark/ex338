defmodule Ex338.Repo.Migrations.AddProcessAtToWaiver do
  use Ecto.Migration

  def change do
    alter table(:waivers) do
      add :process_at, :datetime
    end
  end
end
