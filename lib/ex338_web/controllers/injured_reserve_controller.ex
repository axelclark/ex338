defmodule Ex338Web.InjuredReserveController do
  use Ex338Web, :controller
  require Logger

  alias Ex338.{FantasyLeagues, InjuredReserves}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    render(
      conn,
      "index.html",
      fantasy_league: FantasyLeagues.get(league_id),
      injured_reserves: InjuredReserves.list_irs_for_league(league_id)
    )
  end

  def update(conn, %{
        "fantasy_league_id" => league_id,
        "id" => id,
        "injured_reserve" => params
      }) do
    injured_reserve = InjuredReserves.get_ir!(id)

    case InjuredReserves.update_injured_reserve(injured_reserve, params) do
      {:ok, %{injured_reserve: _ir}} ->
        conn
        |> put_flash(:info, "IR successfully processed")
        |> redirect(to: Routes.fantasy_league_injured_reserve_path(conn, :index, league_id))

      {:error, _action, error, _} ->
        Logger.error(inspect(error))

        conn
        |> put_flash(:error, "Error processing IR")
        |> redirect(to: Routes.fantasy_league_injured_reserve_path(conn, :index, league_id))
    end
  end
end
