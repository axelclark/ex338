defmodule Ex338.Repo.Migrations.AddNullConstraintsToRosterPosition do
  use Ecto.Migration

  def up do
    create constraint(:roster_positions, :position_not_null,
                                         check: "position IS NOT NULL")
  end

  def down do
    drop constraint(:roster_positions, :position_not_null)
  end
end
