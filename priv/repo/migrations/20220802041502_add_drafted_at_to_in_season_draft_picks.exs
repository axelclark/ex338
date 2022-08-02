defmodule Ex338.Repo.Migrations.AddDraftedAtToInSeasonDraftPicks do
  use Ecto.Migration

  def change do
    alter table(:in_season_draft_picks) do
      add(:drafted_at, :utc_datetime)
    end
  end
end
