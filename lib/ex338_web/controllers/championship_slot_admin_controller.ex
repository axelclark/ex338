defmodule Ex338Web.ChampionshipSlotAdminController do
  use Ex338Web, :controller

  alias Ex338.Championships

  def create(conn, %{"fantasy_league_id" => league_id, "championship_id" => id}) do
    case Championships.create_slots_for_league(id, league_id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Slots successfully created.")
        |> redirect(to: ~p"/fantasy_leagues/#{league_id}/championships")

      {:error, _} ->
        conn
        |> put_flash(:info, "Error when creating slots.")
        |> redirect(to: ~p"/fantasy_leagues/#{league_id}/championships")
    end
  end
end
