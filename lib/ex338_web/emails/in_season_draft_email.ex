defmodule Ex338Web.InSeasonDraftEmail do
  @moduledoc false

  require Logger

  alias Ex338.{FantasyLeague, InSeasonDraftPick, User}
  alias Ex338Web.{Mailer, NotificationEmail}

  def send_update(league_id, sport_id) do
    num_picks = 5
    email_data = in_season_draft_email_data(league_id, sport_id, num_picks)
    email = NotificationEmail.in_season_draft_update(email_data)

    case Mailer.deliver(email) do
      {:ok, result} ->
        Logger.info("Sent notification email")
        {:ok, result}

      {:error, reason} ->
        Logger.error("Error sending email: #{inspect(reason)}")
        {:error, inspect(reason)}
    end
  end

  defp in_season_draft_email_data(league_id, sport_id, num_picks) do
    %{
      league: FantasyLeague.Store.get(league_id),
      recipients: User.Store.get_league_and_admin_emails(league_id),
      last_picks: InSeasonDraftPick.Store.last_picks(league_id, sport_id, num_picks),
      next_picks: InSeasonDraftPick.Store.next_picks(league_id, sport_id, num_picks)
    }
  end
end
