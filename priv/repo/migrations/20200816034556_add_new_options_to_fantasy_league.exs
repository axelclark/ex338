defmodule Ex338.Repo.Migrations.AddNewOptionsToFantasyLeague do
  use Ecto.Migration

  def change do
    alter table(:fantasy_leagues) do
      add(:only_flex?, :boolean, default: false)
      add(:must_draft_each_sport?, :boolean, default: false)
    end
  end
end
