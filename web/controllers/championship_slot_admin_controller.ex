defmodule Ex338.ChampionshipSlotAdminController do
  use Ex338.Web, :controller

  alias Ex338.{ChampionshipSlot}

  def create(conn, %{"fantasy_league_id" => league_id, "championship_id" => id}) do
    case ChampionshipSlot.Store.create_slots_for_league(id, league_id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Slots successfully created.")
        |> redirect(to: fantasy_league_championship_path(conn, :show, league_id, id))

      {:error, _} ->
        conn
        |> put_flash(:info, "Error when creating slots.")
        |> redirect(to: fantasy_league_championship_path(conn, :show, league_id, id))
    end
  end
end
