defmodule Ex338.NotificationEmail do
  use Phoenix.Swoosh, view: Ex338.EmailView, layout: {Ex338.LayoutView, :email}

  def draft_pick_update(draft_pick) do
    new
    |> to("axelclark2@yahoo.com")
    |> from({"338 Commish", "no-reply@338admin.com"})
    |> subject("338 Draft Pick Update")
    |> render_body("draft_pick_update.html", %{draft_pick: draft_pick})
  end

  def draft_update(conn, league, last_picks, next_picks, recipients) do
    new
    |> to(recipients)
    |> from({"338 Commish", "no-reply@338admin.com"})
    |> subject("338 Draft Update")
    |> render_body("draft_update.html", %{league: league, last_picks: last_picks,
                                          next_picks: next_picks, conn: conn})
  end
end
