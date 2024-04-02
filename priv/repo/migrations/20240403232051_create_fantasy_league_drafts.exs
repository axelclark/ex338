defmodule Ex338.Repo.Migrations.CreateFantasyLeagueDrafts do
  @moduledoc false
  use Ecto.Migration

  def change do
    create table(:fantasy_league_drafts) do
      add :fantasy_league_id, references(:fantasy_leagues, on_delete: :delete_all)
      add :chat_id, references(:chats, on_delete: :nothing)
      add :championship_id, references(:championships, on_delete: :delete_all)

      timestamps()
    end

    create index(:fantasy_league_drafts, [:fantasy_league_id])
    create index(:fantasy_league_drafts, [:championship_id])

    create unique_index(:fantasy_league_drafts, [:championship_id, :fantasy_league_id])
    create unique_index(:fantasy_league_drafts, [:chat_id])
  end
end
