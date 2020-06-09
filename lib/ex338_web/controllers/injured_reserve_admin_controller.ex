defmodule Ex338Web.InjuredReserveAdminController do
  use Ex338Web, :controller

  alias Ex338.InjuredReserves

  def update(conn, %{"fantasy_league_id" => league_id, "id" => ir_id, "status" => status}) do
    case InjuredReserves.process_ir(ir_id, %{"status" => status}) do
      {:ok, %{ir: _ir}} ->
        conn
        |> put_flash(:info, "IR successfully processed")
        |> redirect(to: Routes.fantasy_league_injured_reserve_path(conn, :index, league_id))

      {:error, error} ->
        conn
        |> put_flash(:error, inspect(error))
        |> redirect(to: Routes.fantasy_league_injured_reserve_path(conn, :index, league_id))
    end
  end
end
