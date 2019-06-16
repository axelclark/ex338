defmodule Ex338.Repo.Migrations.AddDraftMethodToFantasyLeagues do
  use Ecto.Migration

  def up do
    FantasyLeagueDraftMethodEnum.create_type()

    alter table("fantasy_leagues") do
      add(:draft_method, :fantasy_league_draft_method, default: "redraft")
    end
  end

  def down do
    alter table("fantasy_leagues") do
      remove(:draft_method)
    end

    FantasyLeagueDraftMethodEnum.drop_type()
  end
end
