defmodule Ex338.Repo.Migrations.CreateTrade do
  use Ecto.Migration

  def change do
    create table(:trades) do
      add :status, :string
      add :additional_terms, :string

      timestamps()
    end

  end
end
