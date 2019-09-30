defmodule Ex338.Repo.Migrations.CreateUniqueIndexForInSeasonDraftPicks do
  use Ecto.Migration

  def up do
    create(unique_index(:in_season_draft_picks, [:fantasy_league_id, :drafted_player_id]))
  end

  def down do
    drop(unique_index(:in_season_draft_picks, [:fantasy_league_id, :drafted_player_id]))
  end
end
