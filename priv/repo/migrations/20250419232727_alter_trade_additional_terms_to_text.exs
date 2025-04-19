defmodule Ex338.Repo.Migrations.AlterTradeAdditionalTermsToText do
  use Ecto.Migration

  def change do
    alter table(:trades) do
      modify :additional_terms, :text, from: :string
    end
  end
end
