defmodule Ex338.RosterTransactionController do
  use Ex338.Web, :controller

  alias Ex338.{FantasyLeague, RosterTransaction}

  def index(conn, %{"fantasy_league_id" => league_id}) do
    fantasy_league = FantasyLeague |> Repo.get(league_id)

    roster_transactions = RosterTransaction
                          |> RosterTransaction.by_league(league_id)
                          |> preload(transaction_line_items: [:fantasy_team,
                                     fantasy_player: :sports_league])
                          |> Repo.all

    render(conn, "index.html", fantasy_league: fantasy_league,
                               roster_transactions: roster_transactions)
  end
end
