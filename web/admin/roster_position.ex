defmodule Ex338.ExAdmin.RosterPosition do
  @moduledoc false

  use ExAdmin.Register

  register_resource Ex338.RosterPosition do

    form roster_position do
      inputs do
        input roster_position, :position,
                               collection: Ex338.RosterPosition.positions
        input roster_position, :fantasy_team,
                               collection: Ex338.FantasyTeam.all
        input roster_position, :fantasy_player,
                               collection: Ex338.FantasyPlayer.all
      end
    end
  end
end
