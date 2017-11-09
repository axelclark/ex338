defmodule Ex338Web.ExAdmin.RosterPosition do
  @moduledoc false

  use ExAdmin.Register

  alias Ex338.FantasyTeam

  register_resource Ex338.RosterPosition do

    form roster_position do
      inputs do
        input roster_position, :position,
          collection: Ex338.RosterPosition.Store.all_positions()
        input roster_position, :fantasy_team,
          collection: Ex338.Repo.all(FantasyTeam.alphabetical(FantasyTeam))
        input roster_position, :fantasy_player,
          collection: Ex338.FantasyPlayer.Store.get_all_players()
        input roster_position, :status,
          collection: Ex338.RosterPosition.status_options()
        input roster_position, :active_at
      end
    end
  end
end
