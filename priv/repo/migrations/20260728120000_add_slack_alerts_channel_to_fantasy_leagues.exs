defmodule Ex338.Repo.Migrations.AddSlackAlertsChannelToFantasyLeagues do
  use Ecto.Migration

  def change do
    alter table(:fantasy_leagues) do
      add(:slack_alerts_channel, :string)
    end
  end
end
