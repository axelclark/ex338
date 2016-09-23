defmodule Ex338.Repo.Migrations.AddDefaultStatusToWaiver do
  use Ecto.Migration

  def up do
    alter table(:waivers) do
      modify :status, :string, default: "pending"
    end
  end

  def down do
    alter table(:waivers) do
      modify :status, :string
    end
  end
end
