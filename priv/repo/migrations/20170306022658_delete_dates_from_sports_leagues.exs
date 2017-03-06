defmodule Ex338.Repo.Migrations.DeleteDatesFromSportsLeagues do
  use Ecto.Migration

  def up do
    alter table(:sports_leagues) do
      remove :waiver_deadline
      remove :trade_deadline
      remove :championship_date
    end
  end

  def down do
    alter table(:sports_leagues) do
      add :waiver_deadline, :utc_datetime
      add :trade_deadline, :utc_datetime
      add :championship_date, :utc_datetime
    end
  end
end
