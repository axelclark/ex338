defmodule Ex338.Repo.Migrations.UpdateDefaultForMustDraftEachSport do
  use Ecto.Migration

  def up do
    alter table(:fantasy_leagues) do
      modify(:must_draft_each_sport?, :boolean, default: true)
    end
  end

  def down do
    alter table(:fantasy_leagues) do
      modify(:must_draft_each_sport?, :boolean, default: false)
    end
  end
end
