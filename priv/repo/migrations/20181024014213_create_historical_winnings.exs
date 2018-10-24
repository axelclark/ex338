defmodule Ex338.Repo.Migrations.CreateHistoricalWinnings do
  use Ecto.Migration

  def change do
    create table(:historical_winnings) do
      add :team, :string
      add :amount, :integer

      timestamps()
    end
  end
end
