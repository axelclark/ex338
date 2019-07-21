defmodule Ex338.Repo.Migrations.AddAcqMethodToRosterPositions do
  use Ecto.Migration

  def change do
    alter table(:roster_positions) do
      add(:acq_method, :string, default: "unknown")
    end
  end
end
