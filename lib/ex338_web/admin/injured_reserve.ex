defmodule Ex338Web.ExAdmin.InjuredReserve do
  @moduledoc false

  use ExAdmin.Register

  alias Ex338.FantasyTeam

  register_resource Ex338.InjuredReserve do

    form waiver do
      inputs do
        input waiver, :fantasy_team,
          collection: Ex338.Repo.all(FantasyTeam.alphabetical(FantasyTeam))
        input waiver, :add_player,
          collection: Ex338.FantasyPlayer.get_all_players()
        input waiver, :remove_player,
          collection: Ex338.FantasyPlayer.get_all_players()
        input waiver, :replacement_player,
          collection: Ex338.FantasyPlayer.get_all_players()
        input waiver, :status, collection: Ex338.InjuredReserve.status_options()
      end
    end

  end
end
