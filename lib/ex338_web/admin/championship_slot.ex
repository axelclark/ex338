defmodule Ex338Web.ExAdmin.ChampionshipSlot do
  @moduledoc false

  use ExAdmin.Register

  register_resource Ex338.ChampionshipSlot do
    form championship_slot do
      inputs do
        input(championship_slot, :slot)

        input(
          championship_slot,
          :roster_position,
          collection: Ex338.RosterPositions.list_all(),
          fields: [:id, :fantasy_team_id, :status]
        )

        input(
          championship_slot,
          :championship,
          collection: Ex338.Championships.Championship.all(),
          fields: [:title, :year]
        )
      end
    end
  end
end
