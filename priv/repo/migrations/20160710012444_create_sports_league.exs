defmodule Ex338.Repo.Migrations.CreateSportsLeague do
  use Ecto.Migration

  def change do
    create table(:sports_leagues) do
      add :league_name, :string
      add :waiver_deadline, :datetime
      add :trade_deadline, :datetime
      add :championship_date, :datetime

      timestamps()
    end

  end
end
