defmodule Ex338.Repo.Migrations.AddDefaultStatusToRosterPosition do
  use Ecto.Migration

  def up do
    alter table(:roster_positions) do
      modify :position, :string, default: "Unassigned"
    end
  end

  def down do
    alter table(:roster_positions) do
      modify :position, :string
    end
  end
end
