defmodule Ex338.Repo.Migrations.AddDraftPickToFantasyPlayer do
  use Ecto.Migration

  def change do
    alter table(:fantasy_players) do
      add :draft_pick, :boolean, default: false
    end
  end
end
