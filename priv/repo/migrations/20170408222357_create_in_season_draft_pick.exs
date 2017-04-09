defmodule Ex338.Repo.Migrations.CreateInSeasonDraftPick do
  use Ecto.Migration

  def change do
    create table(:in_season_draft_picks) do
      add :position, :integer
      add :draft_pick_asset_id, references(:roster_positions, on_delete: :nothing)
      add :drafted_player_id, references(:fantasy_players, on_delete: :nothing)
      add :championship_id, references(:championships, on_delete: :nothing)

      timestamps()
    end
    create index(:in_season_draft_picks, [:draft_pick_asset_id])
    create index(:in_season_draft_picks, [:drafted_player_id])
    create index(:in_season_draft_picks, [:championship_id])

  end
end
