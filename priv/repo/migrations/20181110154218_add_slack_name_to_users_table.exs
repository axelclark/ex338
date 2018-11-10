defmodule Ex338.Repo.Migrations.AddSlackNameToUsersTable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :slack_name, :text, default: ""
    end
  end
end
