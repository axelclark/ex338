defmodule Ex338.Repo.Migrations.AddHideWaiversToSportsLeague do
  use Ecto.Migration

  def change do
    alter table(:sports_leagues) do
      add :hide_waivers, :boolean, default: false
    end
  end
end
