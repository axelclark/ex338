defmodule Ex338.ExAdmin.InSeasonDraftPick do
  @moduledoc false
  use ExAdmin.Register

  register_resource Ex338.InSeasonDraftPick do
    form in_season_draft_pick do
      inputs do
        input in_season_draft_pick, :position
        input in_season_draft_pick, :draft_pick_asset,
          collection: Ex338.Repo.all(Ex338.RosterPosition)
        input in_season_draft_pick, :drafted_player,
          collection: Ex338.Repo.all(Ex338.FantasyPlayer)
        input in_season_draft_pick, :championship,
          collection: Ex338.Repo.all(Ex338.Championship)
      end
    end
  end
end
