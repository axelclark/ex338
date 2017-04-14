defmodule Ex338.InSeasonDraftPick.Admin do
  @moduledoc false

  alias Ex338.{Commish, InSeasonDraftPick}
  alias Ecto.Multi

  def update(draft_pick, params) do
    league_id = draft_pick.draft_pick_asset.fantasy_team.fantasy_league_id

    Multi.new
    |> Multi.update(:in_season_draft_pick,
       InSeasonDraftPick.owner_changeset(draft_pick, params))
    |> Multi.run(:email, &(Commish.InSeasonDraftEmail.send_update(&1, league_id)))
  end
end
