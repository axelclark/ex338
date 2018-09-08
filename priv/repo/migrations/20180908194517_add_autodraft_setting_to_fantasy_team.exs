defmodule Ex338.Repo.Migrations.AddAutodraftSettingToFantasyTeam do
  use Ecto.Migration

  def up do
    FantasyTeamAutodraftSettingEnum.create_type
    alter table("fantasy_teams") do
      add :autodraft_setting, :fantasy_team_autodraft_setting, default: "on"
    end
  end

  def down do
    alter table("fantasy_teams") do
      remove :autodraft_setting
    end
    FantasyTeamAutodraftSettingEnum.drop_type
  end
end
