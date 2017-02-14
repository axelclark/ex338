defmodule Ex338.Repo.Migrations.UpdatePointsWinningsToFloat do
  use Ecto.Migration

  def change do
    alter table(:champ_with_events_results) do
      modify :points, :float
      modify :winnings, :float
    end
  end
end
