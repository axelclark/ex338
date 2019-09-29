defmodule Ex338.Repo.Migrations.AddFantasyLeagueToInSeasonDraftPick do
  use Ecto.Migration

  def change do
    alter table(:in_season_draft_picks) do
      add(
        :fantasy_league_id,
        references(:fantasy_leagues, on_delete: :delete_all)
      )
    end

    create(index(:in_season_draft_picks, [:fantasy_league_id]))
  end
end
