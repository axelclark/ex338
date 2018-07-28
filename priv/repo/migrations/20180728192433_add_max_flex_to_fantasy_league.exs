defmodule Ex338.Repo.Migrations.AddMaxFlexToFantasyLeague do
  use Ecto.Migration

  def change do
    alter table(:fantasy_leagues) do
      add :max_flex_spots, :integer, default: 6
    end
  end
end
