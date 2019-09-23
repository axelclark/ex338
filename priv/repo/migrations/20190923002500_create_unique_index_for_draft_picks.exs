defmodule Ex338.Repo.Migrations.CreateUniqueIndexForDraftPicks do
  use Ecto.Migration

  def up do
    create(unique_index(:draft_picks, [:fantasy_league_id, :fantasy_player_id]))
  end

  def down do
    drop(unique_index(:draft_picks, [:fantasy_league_id, :fantasy_player_id]))
  end
end
