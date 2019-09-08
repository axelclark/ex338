defmodule Ex338.Repo.Migrations.AddStartEndDatesToFantasyPlayer do
  use Ecto.Migration

  def change do
    alter table(:fantasy_players) do
      add(:available_starting_at, :utc_datetime)
      add(:archived_at, :utc_datetime)
    end
  end
end
