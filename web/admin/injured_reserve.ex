defmodule Ex338.ExAdmin.InjuredReserve do
  @moduledoc false

  use ExAdmin.Register

  register_resource Ex338.InjuredReserve do

    form waiver do
      inputs do
        input waiver, :fantasy_team, collection: Ex338.FantasyTeam.all
        input waiver, :add_player, collection: Ex338.FantasyPlayer.all
        input waiver, :remove_player, collection: Ex338.FantasyPlayer.all
        input waiver, :replacement_player, collection: Ex338.FantasyPlayer.all
        input waiver, :status, collection: Ex338.InjuredReserve.status_options
      end
    end

  end
end
