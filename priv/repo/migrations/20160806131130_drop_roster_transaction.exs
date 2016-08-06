defmodule Ex338.Repo.Migrations.DropRosterTransaction do
  use Ecto.Migration

  def up do
    drop table(:roster_transactions)
  end

  def down do
    create table(:roster_transactions) do
      add :category, :string
      add :additional_terms, :text
      add :roster_transaction_on, :datetime

      timestamps()
    end
  end
end
