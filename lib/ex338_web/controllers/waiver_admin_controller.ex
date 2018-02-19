defmodule Ex338Web.WaiverAdminController do
  use Ex338Web, :controller

  alias Ex338.{Waiver, Waiver.Store, Authorization}

  import Canary.Plugs

  plug(
    :load_and_authorize_resource,
    model: Waiver,
    only: [:edit, :update],
    preload: [:fantasy_team, :add_fantasy_player, :drop_fantasy_player],
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  def edit(conn, _) do
    waiver = conn.assigns.waiver
    changeset = Waiver.changeset(waiver)

    render(conn, "edit.html", waiver: waiver, changeset: changeset)
  end

  def update(conn, %{"id" => _, "waiver" => params}) do
    waiver = conn.assigns.waiver

    result = Store.process_waiver(waiver, params)

    case result do
      {:ok, %{waiver: _waiver}} ->
        conn
        |> put_flash(:info, "Waiver successfully processed")
        |> redirect(
          to: fantasy_league_waiver_path(conn, :index, waiver.fantasy_team.fantasy_league_id)
        )

      {:error, _, changeset, _} ->
        render(conn, "edit.html", waiver: waiver, changeset: changeset)
    end
  end
end
