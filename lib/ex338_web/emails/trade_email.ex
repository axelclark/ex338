defmodule Ex338Web.TradeEmail do
  @moduledoc false

  use Phoenix.Swoosh, view: Ex338Web.EmailView, layout: {Ex338Web.LayoutView, :email}

  @commish {"338 Commish", "no-reply@338admin.com"}

  def pending(conn, league, trade, recipients) do
    new()
    |> to(recipients)
    |> from(@commish)
    |> subject("New 338 #{league.fantasy_league_name} Trade for Approval")
    |> render_body("pending_trade.html", %{conn: conn, league: league, trade: trade})
  end

  def propose(conn, league, trade, recipients) do
    new()
    |> to(recipients)
    |> from(@commish)
    |> subject("#{trade.submitted_by_team.team_name} proposed a 338 trade")
    |> render_body("proposed_trade.html", %{conn: conn, league: league, trade: trade})
  end

  def reject(conn, league, trade, recipients, fantasy_team) do
    new()
    |> to(recipients)
    |> from(@commish)
    |> subject("Proposed trade rejected by #{fantasy_team.team_name}")
    |> render_body("rejected_trade.html", %{
      conn: conn,
      fantasy_team: fantasy_team,
      league: league,
      trade: trade
    })
  end
end
