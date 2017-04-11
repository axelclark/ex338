defmodule Ex338.InSeasonDraftPickController do
  use Ex338.Web, :controller

  alias Ex338.{InSeasonDraftPick, Authorization}

  import Canary.Plugs

  plug :load_and_authorize_resource, model: InSeasonDraftPick,
    only: [:edit],
    preload: [draft_pick_asset: [fantasy_team: :owners]],
    unauthorized_handler: {Authorization, :handle_unauthorized}

  def edit(conn, %{"id" => id}) do
    pick = InSeasonDraftPick.Store.pick_with_assocs(id)
    changeset = InSeasonDraftPick.Store.changeset(pick)

    render(
      conn,
      "edit.html",
      in_season_draft_pick: pick,
      changeset: changeset,
      fantasy_players: InSeasonDraftPick.Store.available_players(pick),
    )
  end
end
