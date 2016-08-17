defmodule Ex338.NotificationEmail do
  use Phoenix.Swoosh, view: Ex338.EmailView, layout: {Ex338.LayoutView, :email}

  def draft_pick_update(draft_pick) do
    new
    |> to({"Axel", "axelclark2@yahoo.com"})
    |> from({"Axel", "no-reply@338admin.com"})
    |> subject("Draft Pick Update")
    |> render_body("draft_pick_update.html", %{draft_pick: draft_pick})
  end
end
