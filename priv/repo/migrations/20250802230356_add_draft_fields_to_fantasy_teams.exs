defmodule Ex338.Repo.Migrations.AddDraftFieldsToFantasyTeams do
  use Ecto.Migration

  def change do
    alter table(:fantasy_teams) do
      add :draft_grade, :string
      add :draft_analysis, :text
    end
  end
end
