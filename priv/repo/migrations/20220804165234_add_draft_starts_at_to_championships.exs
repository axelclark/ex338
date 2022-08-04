defmodule Ex338.Repo.Migrations.AddDraftStartsAtToChampionships do
  use Ecto.Migration

  def change do
    alter table(:championships) do
      add(:draft_starts_at, :utc_datetime)
    end
  end
end
