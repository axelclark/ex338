defmodule Ex338Web.InSeasonDraftOrderController do
  use Ex338Web, :controller

  alias Ex338.InSeasonDraftPicks

  def create(conn, %{"fantasy_league_id" => league_id, "championship_id" => champ_id}) do
    case InSeasonDraftPicks.create_picks_for_league(league_id, champ_id) do
      {:ok, new_picks} ->
        conn
        |> put_flash(:info, "#{num_picks(new_picks)} picks successfully created.")
        |> redirect(to: Routes.fantasy_league_championship_path(conn, :show, league_id, champ_id))

      {:error, _, changeset, _} ->
        conn
        |> put_flash(:info, "Error when creating draft picks: #{inspect(changeset.errors)}")
        |> redirect(to: Routes.fantasy_league_championship_path(conn, :show, league_id, champ_id))
    end
  end

  defp num_picks(picks) do
    picks
    |> Enum.count()
    |> Integer.to_string()
  end
end
