defmodule Ex338.Repo.Migrations.CreateSportsLeague do
  use Ecto.Migration

  def change do
    create table(:sports_leagues) do
      add :league_name, :string
      add :waiver_deadline, :utc_datetime
      add :trade_deadline, :utc_datetime
      add :championship_date, :utc_datetime

      timestamps()
    end

  end
end
