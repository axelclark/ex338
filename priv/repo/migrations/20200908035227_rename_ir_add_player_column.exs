defmodule Ex338.Repo.Migrations.RenameIRAddPlayerColumn do
  use Ecto.Migration

  def change do
    drop(index("injured_reserves", [:add_player_id]))
    rename(table("injured_reserves"), :add_player_id, to: :injured_player_id)
    create(index("injured_reserves", [:injured_player_id]))
  end
end
