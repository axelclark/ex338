defmodule Ex338.Repo.Migrations.AddRulesToOwners do
  use Ecto.Migration

  def up do
    OwnerRulesEnum.create_type()

    alter table("owners") do
      add(:rules, OwnerRulesEnum.type(), default: "unaccepted")
    end
  end

  def down do
    alter table("owners") do
      remove(:rules)
    end

    OwnerRulesEnum.drop_type()
  end
end
