defmodule Ex338.NotificationEmail do
  use Phoenix.Swoosh, view: Ex338.EmailView, layout: {Ex338.LayoutView, :email}

  def draft_update(conn, league, last_picks, next_picks, recipients, admins) do
    new
    |> to(recipients)
    |> cc(admins)
    |> from({"338 Commish", "no-reply@338admin.com"})
    |> subject(headline(last_picks))
    |> render_body("draft_update.html", %{league: league, last_picks: last_picks,
                                          next_picks: next_picks, conn: conn})
  end

  defp headline(last_picks) do
    last_pick = Enum.at(last_picks, 0)

    "338 Draft: #{last_pick.fantasy_team.team_name} selects #{last_pick.fantasy_player.player_name} (##{last_pick.draft_position})"
  end
end
