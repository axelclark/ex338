defmodule Ex338Web.TradeVoteController do
  use Ex338Web, :controller

  import Canary.Plugs

  alias Ex338.Accounts
  alias Ex338.FantasyTeams.FantasyTeam
  alias Ex338.Trades
  alias Ex338Web.Authorization
  alias Ex338Web.Mailer
  alias Ex338Web.TradeEmail

  plug(
    :load_and_authorize_resource,
    model: FantasyTeam,
    only: [:create],
    preload: [:owners, :fantasy_league],
    persisted: true,
    id_name: "fantasy_team_id",
    unauthorized_handler: {Authorization, :handle_unauthorized}
  )

  def create(conn, %{"fantasy_team_id" => _id, "trade_vote" => vote_params}) do
    team = conn.assigns.fantasy_team

    vote_params =
      vote_params
      |> Map.put("user_id", conn.assigns.current_user.id)
      |> Map.put("fantasy_team_id", team.id)

    case Trades.create_vote(vote_params) do
      {:ok, vote} ->
        trade = Trades.find!(vote.trade_id)

        if trade.status == "Proposed" do
          trade
          |> Trades.maybe_update_for_league_vote()
          |> maybe_send_trade_email(conn, team)
        end

        conn
        |> put_flash(:info, "Vote successfully submitted.")
        |> redirect(to: ~p"/fantasy_leagues/#{team.fantasy_league_id}/trades")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "#{parse_errors(changeset.errors)}")
        |> redirect(to: ~p"/fantasy_leagues/#{team.fantasy_league_id}/trades")
    end
  end

  ## Helpers

  # create

  defp maybe_send_trade_email(%{status: "Rejected"} = trade, conn, team) do
    league = trade.submitted_by_team.fantasy_league
    admin_emails = Accounts.get_admin_emails()
    recipients = Enum.uniq(Trades.Trade.get_teams_emails(trade) ++ admin_emails)

    conn
    |> TradeEmail.reject(league, trade, recipients, team)
    |> Mailer.deliver()
    |> Mailer.handle_delivery()
  end

  defp maybe_send_trade_email(%{status: "Pending"} = trade, conn, _team) do
    league = trade.submitted_by_team.fantasy_league
    recipients = Accounts.get_league_and_admin_emails(league.id)

    conn
    |> TradeEmail.pending(league, trade, recipients)
    |> Mailer.deliver()
    |> Mailer.handle_delivery()
  end

  defp maybe_send_trade_email(trade, _conn, _team), do: trade

  defp parse_errors(errors) do
    case Keyword.get(errors, :trade) do
      nil -> inspect(errors)
      {trade_error, _} -> trade_error
    end
  end
end
