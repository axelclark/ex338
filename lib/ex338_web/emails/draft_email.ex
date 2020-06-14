defmodule Ex338Web.DraftEmail do
  @moduledoc false

  require Logger

  alias Ex338.{FantasyLeagues, DraftPicks, DraftPicks.DraftPick, Accounts}
  alias Ex338Web.{Mailer, NotificationEmail}

  def send_update(%DraftPick{fantasy_league_id: league_id}) do
    league_id
    |> email_data()
    |> NotificationEmail.draft_update()
    |> Mailer.deliver()
    |> Mailer.handle_delivery()
  end

  defp email_data(league_id) do
    %{
      league: FantasyLeagues.get(league_id),
      recipients: Accounts.get_league_and_admin_emails(league_id),
      last_picks: DraftPicks.get_last_picks(league_id),
      next_picks: DraftPicks.get_next_picks(league_id)
    }
  end
end
