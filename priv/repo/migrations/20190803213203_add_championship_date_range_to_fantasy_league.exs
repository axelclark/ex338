defmodule Ex338.Repo.Migrations.AddChampionshipDateRangeToFantasyLeague do
  use Ecto.Migration

  def change do
    alter table(:fantasy_leagues) do
      add(:championships_start_at, :utc_datetime)
      add(:championships_end_at, :utc_datetime)
    end
  end
end
