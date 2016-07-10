defmodule Ex338.Repo.Migrations.CreateRosterTransaction do
  use Ecto.Migration

  def change do
    create table(:roster_transactions) do
      add :category, :string
      add :additional_terms, :text
      add :roster_transaction_on, :datetime

      timestamps()
    end

  end
end
