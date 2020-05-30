defmodule Ex338.Repo.Migrations.CreateFuturePicks do
  use Ecto.Migration

  def change do
    create table(:future_picks) do
      add(:round, :integer)
      add(:original_team_id, references(:fantasy_teams, on_delete: :delete_all))
      add(:current_team_id, references(:fantasy_teams, on_delete: :delete_all))

      timestamps()
    end

    create(index(:future_picks, [:original_team_id]))
    create(index(:future_picks, [:current_team_id]))
  end
end
