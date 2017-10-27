defmodule Ex338.Repo.Migrations.ChangeDecimalToFloatOnDraftPick do
  use Ecto.Migration

  def up do
    alter table(:draft_picks) do
      modify :draft_position, :float
    end
  end

  def down do
    alter table(:draft_picks) do
      modify :draft_position, :decimal, precision: 5, scale: 2
    end
  end
end
