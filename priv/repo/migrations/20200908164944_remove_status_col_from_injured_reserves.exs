defmodule Ex338.Repo.Migrations.RemoveStatusColFromInjuredReserves do
  use Ecto.Migration

  def up do
    alter table("injured_reserves") do
      remove(:status)
    end
  end

  def down do
    alter table("injured_reserves") do
      add(:status, :string)
    end
  end
end
