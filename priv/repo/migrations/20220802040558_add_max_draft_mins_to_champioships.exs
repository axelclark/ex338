defmodule Ex338.Repo.Migrations.AddMaxDraftMinsToChampioships do
  use Ecto.Migration

  def change do
    alter table(:championships) do
      add(:max_draft_mins, :integer, default: 5)
    end
  end
end
