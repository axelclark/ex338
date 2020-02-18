defmodule Ex338.Repo.Migrations.DeleteUnusedFantasyPlayersFields do
  use Ecto.Migration

  def up do
    alter table(:fantasy_players) do
      remove(:start_year)
      remove(:end_year)
    end
  end

  def down do
    alter table(:fantasy_players) do
      add(:start_year, :integer, default: 2017)
      add(:end_year, :integer)
    end
  end
end
