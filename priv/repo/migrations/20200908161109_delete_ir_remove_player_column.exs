defmodule Ex338.Repo.Migrations.DeleteIrRemovePlayerColumn do
  use Ecto.Migration

  def up do
    drop(index(:injured_reserves, [:remove_player_id]))

    alter table("injured_reserves") do
      remove(:remove_player_id)
    end
  end

  def down do
    alter table("injured_reserves") do
      add(:remove_player_id, references(:fantasy_players, on_delete: :nothing))
    end

    create(index(:injured_reserves, [:remove_player_id]))
  end
end
