defmodule Ex338.Repo.Migrations.CreateChampionshipSlot do
  use Ecto.Migration

  def change do
    create table(:championship_slots) do
      add :slot, :integer
      add :roster_position_id, references(:roster_positions, on_delete: :nothing)
      add :championship_id, references(:championships, on_delete: :nothing)

      timestamps()
    end
    create index(:championship_slots, [:roster_position_id])
    create index(:championship_slots, [:championship_id])

  end
end
