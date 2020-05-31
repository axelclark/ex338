defmodule Ex338.Repo.Migrations.AddFuturePickToTradeLineItems do
  use Ecto.Migration

  def change do
    alter table(:trade_line_items) do
      add(:future_pick_id, references(:future_picks, on_delete: :delete_all))
    end

    create(index(:trade_line_items, [:future_pick_id]))
  end
end
