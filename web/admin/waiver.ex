defmodule Ex338.ExAdmin.Waiver do
  use ExAdmin.Register

  register_resource Ex338.Waiver do

    form waiver do
      inputs do
        input waiver, :fantasy_team, collection: Ex338.FantasyTeam.all
        input waiver, :add_fantasy_player, collection: Ex338.FantasyPlayer.all
        input waiver, :drop_fantasy_player, collection: Ex338.FantasyPlayer.all
        input waiver, :status, collection: Ex338.Waiver.status_options
      end
    end
  end
end
