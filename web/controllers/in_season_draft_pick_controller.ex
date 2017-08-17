defmodule Ex338.InSeasonDraftPickController do
  use Ex338.Web, :controller

  alias Ex338.{InSeasonDraftPick, Authorization, Commish}

  import Canary.Plugs

  plug :load_and_authorize_resource, model: InSeasonDraftPick,
    only: [:edit, :update],
    preload: [:championship, :drafted_player,
             [draft_pick_asset: [:championship_slots, :in_season_draft_picks,
               :fantasy_player, fantasy_team: :owners]]],
    unauthorized_handler: {Authorization, :handle_unauthorized}

  def edit(conn, %{"id" => _id}) do
    pick = conn.assigns.in_season_draft_pick
    changeset = InSeasonDraftPick.Store.changeset(pick)

    render(
      conn,
      "edit.html",
      in_season_draft_pick: pick,
      changeset: changeset,
      fantasy_players: InSeasonDraftPick.Store.available_players(pick),
    )
  end

  def update(conn, %{"id" => _id, "in_season_draft_pick" => params}) do
    pick = conn.assigns.in_season_draft_pick

    case InSeasonDraftPick.Store.draft_player(pick, params) do
      {:ok,  %{update_pick: pick}} ->
        league_id = pick.draft_pick_asset.fantasy_team.fantasy_league_id
        sport_id = pick.championship.sports_league_id
        Commish.InSeasonDraftEmail.send_update(league_id, sport_id)

        conn
        |> put_flash(:info, "Draft pick successfully submitted.")
        |> redirect(to: fantasy_league_championship_path(conn, :show,
                    league_id, pick.championship_id))

      {:error, _, changeset, _} ->
        render(conn, "edit.html",
          draft_pick: pick,
          fantasy_players: InSeasonDraftPick.Store.available_players(pick),
          changeset: changeset
        )
    end
  end
end
