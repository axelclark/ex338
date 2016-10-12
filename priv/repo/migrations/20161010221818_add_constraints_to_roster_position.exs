defmodule Ex338.Repo.Migrations.AddConstraintsToRosterPosition do
  use Ecto.Migration

  def up do
    create unique_index(:roster_positions, [:position, :fantasy_team_id],
      where: "status LIKE 'active' AND position != 'Unassigned'")
  end

  def down do
    drop unique_index(:roster_positions, [:position, :fantasy_team_id],
      where: "status LIKE 'active' AND position != 'Unassigned'")
  end
end
