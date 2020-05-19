defmodule Ex338.Repo.Migrations.DropCoherenceInvitationsTable do
  use Ecto.Migration

  def up do
    drop(table(:invitations))
  end

  def down do
    create table(:invitations) do
      add(:name, :string)
      add(:email, :string)
      add(:token, :string)
      timestamps()
    end

    create(unique_index(:invitations, [:email]))
    create(index(:invitations, [:token]))
  end
end
