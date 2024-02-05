defmodule Ex338Web.InSeasonDraftEmail do
  @moduledoc false

  alias Ex338.Accounts
  alias Ex338.FantasyLeagues
  alias Ex338.InSeasonDraftPicks
  alias Ex338Web.Mailer
  alias Ex338Web.NotificationEmail

  require Logger

  def send_update(pick) do
    num_picks = 5

    pick
    |> in_season_draft_email_data(num_picks)
    |> NotificationEmail.in_season_draft_update()
    |> Mailer.deliver()
    |> Mailer.handle_delivery()
  end

  defp in_season_draft_email_data(pick, num_picks) do
    league_id = pick.draft_pick_asset.fantasy_team.fantasy_league_id
    championship = pick.championship
    picks = InSeasonDraftPicks.all_picks_with_status(league_id, championship)
    last_picks = filter_last_picks(picks, num_picks)
    next_picks = filter_next_picks(picks, num_picks)

    %{
      fantasy_league: FantasyLeagues.get(league_id),
      recipients: Accounts.get_league_and_admin_emails(league_id),
      last_picks: last_picks,
      next_picks: next_picks,
      pick: List.first(last_picks),
      next_pick: List.first(next_picks)
    }
  end

  defp filter_last_picks(picks, num_picks) do
    picks
    |> Enum.filter(&(&1.drafted_player_id != nil))
    |> InSeasonDraftPicks.sort_by_drafted_at()
    |> Enum.take(-num_picks)
    |> Enum.reverse()
  end

  defp filter_next_picks(picks, num_picks) do
    picks
    |> Enum.filter(&(&1.drafted_player_id == nil))
    |> Enum.take(num_picks)
  end
end
