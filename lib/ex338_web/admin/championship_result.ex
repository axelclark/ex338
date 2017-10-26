defmodule Ex338Web.ExAdmin.ChampionshipResult do
  @moduledoc false

  use ExAdmin.Register

  register_resource Ex338.ChampionshipResult do

    form championship_result do
      inputs do
        input championship_result, :championship,
          collection: Ex338.Championship.all()
        input championship_result, :fantasy_player,
          collection: Ex338.FantasyPlayer.get_all_players()
        input championship_result, :rank
        input championship_result, :points
      end
    end

  end
end
