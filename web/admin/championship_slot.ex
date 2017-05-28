defmodule Ex338.ExAdmin.ChampionshipSlot do
  @moduledoc false

  use ExAdmin.Register

  register_resource Ex338.ChampionshipSlot do
    form championship_slot do
      inputs do
        input championship_slot, :slot
        input championship_slot, :roster_position,
          collection: Ex338.RosterPosition.Store.list_all_active(),
          fields: [:id, :fantasy_team_id]
        input championship_slot, :championship,
                                 collection: Ex338.Championship.all(),
                                 fields: [:title, :year]
      end
    end
  end
end
