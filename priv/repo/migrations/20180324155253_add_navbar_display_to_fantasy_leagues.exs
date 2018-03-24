defmodule Ex338.Repo.Migrations.AddNavbarDisplayToFantasyLeagues do
  use Ecto.Migration

  def up do
    FantasyLeagueNavbarDisplayEnum.create_type
    alter table("fantasy_leagues") do
      add :navbar_display, :fantasy_league_navbar_display, default: "primary"
    end
  end

  def down do
    alter table("fantasy_leagues") do
      remove :navbar_display
    end
    FantasyLeagueNavbarDisplayEnum.drop_type
  end
end
