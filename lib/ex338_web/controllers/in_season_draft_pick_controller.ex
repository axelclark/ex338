defmodule Ex338Web.InSeasonDraftPickController do
  use Ex338Web, :controller

  import Canary.Plugs

  alias Ex338.DraftQueues
  alias Ex338.InSeasonDraftPicks
  alias Ex338Web.Authorization

  plug(
    :load_and_authorize_resource,
    model: InSeasonDraftPicks.InSeasonDraftPick,
    only: [:edit, :update],
    preload: [
      :championship,
      :drafted_player,
      [
        draft_pick_asset: [
          :championship_slots,
          :in_season_draft_picks,
          fantasy_player: :sports_league,
          fantasy_team: :owners
        ]
      ]
    ],
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  def edit(conn, %{"id" => _id}) do
    pick = conn.assigns.in_season_draft_pick
    changeset = InSeasonDraftPicks.changeset(pick)

    render(
      conn,
      :edit,
      in_season_draft_pick: pick,
      changeset: changeset,
      fantasy_players: InSeasonDraftPicks.available_players(pick)
    )
  end

  def update(conn, %{"id" => _id, "in_season_draft_pick" => params}) do
    pick = conn.assigns.in_season_draft_pick

    case InSeasonDraftPicks.draft_player(pick, params) do
      {:ok, %{update_pick: pick}} ->
        league_id = pick.draft_pick_asset.fantasy_team.fantasy_league_id
        DraftQueues.reorder_for_league(league_id)
        Ex338Web.InSeasonDraftPickNotifier.send_update(pick)

        conn
        |> put_flash(:info, "Draft pick successfully submitted.")
        |> redirect(to: ~p"/fantasy_leagues/#{league_id}/championships/#{pick.championship_id}")

      {:error, _, changeset, _} ->
        render(
          conn,
          :edit,
          draft_pick: pick,
          fantasy_players: InSeasonDraftPicks.available_players(pick),
          changeset: changeset
        )
    end
  end
end
