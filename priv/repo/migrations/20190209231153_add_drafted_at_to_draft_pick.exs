defmodule Ex338.Repo.Migrations.AddDraftedAtToDraftPick do
  use Ecto.Migration

  def change do
    alter table(:draft_picks) do
      add(:drafted_at, :utc_datetime)
    end
  end
end
