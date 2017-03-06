defmodule Ex338.Repo.Migrations.CreateChampionship do
  use Ecto.Migration

  def change do
    create table(:championships) do
      add :title, :string
      add :category, :string
      add :waiver_deadline_at, :utc_datetime
      add :trade_deadline_at, :utc_datetime
      add :championship_at, :utc_datetime
      add :sports_league_id, references(:sports_leagues, on_delete: :delete_all)

      timestamps()
    end
    create index(:championships, [:sports_league_id])

  end
end
