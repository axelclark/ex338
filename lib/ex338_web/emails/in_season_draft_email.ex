defmodule Ex338Web.InSeasonDraftEmail do
  @moduledoc false

  require Logger

  alias Ex338.{FantasyLeagues, InSeasonDraftPicks, Accounts}
  alias Ex338Web.{Mailer, NotificationEmail}

  def send_update(league_id, sport_id) do
    num_picks = 5

    league_id
    |> in_season_draft_email_data(sport_id, num_picks)
    |> NotificationEmail.in_season_draft_update()
    |> Mailer.deliver()
    |> Mailer.handle_delivery()
  end

  defp in_season_draft_email_data(league_id, sport_id, num_picks) do
    %{
      fantasy_league: FantasyLeagues.get(league_id),
      recipients: Accounts.get_league_and_admin_emails(league_id),
      last_picks: InSeasonDraftPicks.last_picks(league_id, sport_id, num_picks),
      next_picks: InSeasonDraftPicks.next_picks(league_id, sport_id, num_picks)
    }
  end
end
