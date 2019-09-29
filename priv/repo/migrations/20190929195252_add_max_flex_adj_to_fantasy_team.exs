defmodule Ex338.Repo.Migrations.AddMaxFlexAdjToFantasyTeam do
  use Ecto.Migration

  def change do
    alter table(:fantasy_teams) do
      add(:max_flex_adj, :integer, default: 0)
    end
  end
end
