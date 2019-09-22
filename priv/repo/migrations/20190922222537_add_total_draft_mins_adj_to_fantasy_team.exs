defmodule Ex338.Repo.Migrations.AddTotalDraftMinsAdjToFantasyTeam do
  use Ecto.Migration

  def change do
    alter table(:fantasy_teams) do
      add(:total_draft_mins_adj, :integer, default: 0)
    end
  end
end
