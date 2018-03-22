defmodule Ex338.Repo.Migrations.AddSportDraftToFantasyLeague do
  use Ecto.Migration

  def change do
    alter table(:fantasy_leagues) do
      add :sport_draft_id, references(:sports_leagues)
    end
  end
end
