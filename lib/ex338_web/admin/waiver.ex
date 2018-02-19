defmodule Ex338Web.ExAdmin.Waiver do
  @moduledoc false
  use ExAdmin.Register

  register_resource Ex338.Waiver do
    alias Ex338.FantasyTeam

    form waiver do
      inputs do
        input(
          waiver,
          :fantasy_team,
          collection: Ex338.Repo.all(FantasyTeam.alphabetical(FantasyTeam))
        )

        input(
          waiver,
          :add_fantasy_player,
          collection: Ex338.FantasyPlayer.Store.get_all_players()
        )

        input(
          waiver,
          :drop_fantasy_player,
          collection: Ex338.FantasyPlayer.Store.get_all_players()
        )

        input(waiver, :hide_waivers)
        input(waiver, :process_at)
        input(waiver, :status, collection: Ex338.Waiver.status_options())
      end
    end
  end
end
