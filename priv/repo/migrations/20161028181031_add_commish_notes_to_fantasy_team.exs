defmodule Ex338.Repo.Migrations.AddCommishNotesToFantasyTeam do
  use Ecto.Migration

  def change do
    alter table(:fantasy_teams) do
      add :commish_notes, :text, default: ""
    end
  end
end
