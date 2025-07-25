defmodule Ex338.Repo.Migrations.AddDraftPicksLockedToFantasyLeagues do
  use Ecto.Migration

  def change do
    alter table(:fantasy_leagues) do
      add :draft_picks_locked?, :boolean, default: false, null: false
    end
  end
end