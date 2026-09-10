defmodule Ex338.Repo.Migrations.UpdateChampionshipResultPointsToFloat do
  @moduledoc false
  use Ecto.Migration

  def change do
    alter table(:championship_results) do
      modify :points, :float, from: :integer
    end
  end
end
