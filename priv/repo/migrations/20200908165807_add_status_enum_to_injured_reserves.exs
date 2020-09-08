defmodule Ex338.Repo.Migrations.AddStatusEnumToInjuredReserves do
  use Ecto.Migration

  def up do
    InjuredReserveStatusEnum.create_type()

    alter table("injured_reserves") do
      add(:status, InjuredReserveStatusEnum.type(), default: "submitted", null: false)
    end
  end

  def down do
    alter table("injured_reserves") do
      remove(:status)
    end

    InjuredReserveStatusEnum.drop_type()
  end
end
