defmodule Ex338.Repo.Migrations.RemoveRoundColumnFromDraftPick do
  use Ecto.Migration

  def up do
    alter table(:draft_picks) do
      remove :round
    end
  end

  def down do
    alter table(:draft_picks) do
      add :round, :integer 
    end
  end
end
