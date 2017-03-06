defmodule Ex338.Repo.Migrations.AddActiveAtToRosterPosition do
  use Ecto.Migration

  def change do
    alter table(:roster_positions) do
      add :active_at, :utc_datetime, default: fragment("now()")
    end
  end
end
