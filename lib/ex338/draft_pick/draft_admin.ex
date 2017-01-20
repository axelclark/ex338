defmodule Ex338.DraftPick.DraftAdmin do
  @moduledoc false

  alias Ecto.Multi
  alias Ex338.{DraftPick, RosterPosition}

  def draft_player(draft_pick, params) do
    position_params = Map.put(params, "fantasy_team_id", draft_pick.fantasy_team_id)

    Multi.new
    |> Multi.update(:draft_pick, DraftPick.owner_changeset(draft_pick, params))
    |> Multi.insert(:roster_position, RosterPosition.changeset(
         %RosterPosition{position: "Unassigned"}, position_params)
       )
  end
end
