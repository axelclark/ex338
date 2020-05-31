defmodule Ex338.Repo.Migrations.CreateCheckConstraintForTradeLineItems do
  use Ecto.Migration

  def up do
    create(
      constraint(:trade_line_items, :one_asset_per_line_item,
        check:
          "((fantasy_player_id IS NOT NULL OR future_pick_id IS NOT NULL) AND (fantasy_player_id IS NULL OR future_pick_id IS NULL)) "
      )
    )
  end

  def down do
    drop(constraint(:trade_line_items, :one_asset_per_line_item))
  end
end
