defmodule Ex338Web.TradeEmail do
  @moduledoc false

  use Phoenix.Swoosh, view: Ex338Web.EmailView, layout: {Ex338Web.LayoutView, :email}

  @commish {"338 Commish", "no-reply@338admin.com"}

  def new(conn, league, trade, recipients) do
    new()
    |> to(recipients)
    |> from(@commish)
    |> subject("New 338 Trade for Approval")
    |> render_body("new_trade.html", %{conn: conn, league: league, trade: trade})
  end
end
