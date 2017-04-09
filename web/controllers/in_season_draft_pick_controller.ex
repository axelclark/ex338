defmodule Ex338.InSeasonDraftPickController do
  use Ex338.Web, :controller

  alias Ex338.InSeasonDraftPick.Store

  def edit(conn, %{"id" => id}) do
    pick = Store.pick_with_assocs(id)
    changeset = Store.changeset(pick)

    render(
      conn,
      "edit.html",
      in_season_draft_pick: pick,
      changeset: changeset,
      fantasy_players: Store.available_players(pick),
    )
  end
end
