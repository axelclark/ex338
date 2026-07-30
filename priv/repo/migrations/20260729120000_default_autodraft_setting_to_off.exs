defmodule Ex338.Repo.Migrations.DefaultAutodraftSettingToOff do
  use Ecto.Migration

  def up do
    alter table(:fantasy_teams) do
      modify(:autodraft_setting, :fantasy_team_autodraft_setting, default: "off")
    end
  end

  def down do
    alter table(:fantasy_teams) do
      modify(:autodraft_setting, :fantasy_team_autodraft_setting, default: "on")
    end
  end
end
