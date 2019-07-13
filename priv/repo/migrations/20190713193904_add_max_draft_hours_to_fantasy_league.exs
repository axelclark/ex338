defmodule Ex338.Repo.Migrations.AddMaxDraftHoursToFantasyLeague do
  use Ecto.Migration

  def change do
    alter table(:fantasy_leagues) do
      add(:max_draft_hours, :integer, default: 0)
    end
  end
end
