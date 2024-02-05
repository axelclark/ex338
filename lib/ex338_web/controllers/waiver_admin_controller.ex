defmodule Ex338Web.WaiverAdminController do
  use Ex338Web, :controller

  import Canary.Plugs

  alias Ex338.Authorization
  alias Ex338.FantasyLeagues
  alias Ex338.Waivers
  alias Ex338.Waivers.Waiver

  plug(
    :load_and_authorize_resource,
    model: Waiver,
    only: [:edit, :update],
    preload: [:fantasy_team, :add_fantasy_player, :drop_fantasy_player],
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  def edit(conn, _) do
    waiver = conn.assigns.waiver
    league_id = conn.assigns.waiver.fantasy_team.fantasy_league_id
    changeset = Waiver.changeset(waiver)

    render(conn, "edit.html",
      waiver: waiver,
      changeset: changeset,
      fantasy_league: FantasyLeagues.get(league_id)
    )
  end

  def update(conn, %{"id" => _, "waiver" => params}) do
    waiver = conn.assigns.waiver

    result = Waivers.process_waiver(waiver, params)

    case result do
      {:ok, %{waiver: _waiver}} ->
        conn
        |> put_flash(:info, "Waiver successfully processed")
        |> redirect(
          to:
            Routes.fantasy_league_waiver_path(conn, :index, waiver.fantasy_team.fantasy_league_id)
        )

      {:error, _, changeset, _} ->
        league_id = conn.assigns.waiver.fantasy_team.fantasy_league_id

        render(conn, "edit.html",
          waiver: waiver,
          changeset: changeset,
          fantasy_league: FantasyLeagues.get(league_id)
        )
    end
  end
end
