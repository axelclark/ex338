defmodule Ex338.Repo.Migrations.AddInSeasonDraftToChampionship do
  use Ecto.Migration

  def change do
    alter table(:championships) do
      add :in_season_draft, :boolean, default: false
    end
  end
end
