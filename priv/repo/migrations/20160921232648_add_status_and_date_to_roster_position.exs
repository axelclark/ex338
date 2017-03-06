defmodule Ex338.Repo.Migrations.AddStatusAndDateToRosterPosition do
  use Ecto.Migration

  def change do
    alter table(:roster_positions) do
      add :status, :string, default: "active"
      add :released_at, :utc_datetime
    end
  end
end
