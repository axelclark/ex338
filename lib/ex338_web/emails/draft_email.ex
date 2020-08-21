defmodule Ex338Web.DraftEmail do
  @moduledoc false

  require Logger

  alias Ex338.{DraftPicks, DraftPicks.DraftPick, Accounts}
  alias Ex338Web.{DraftPickView, Mailer, NotificationEmail}

  def send_update(%DraftPick{} = draft_pick) do
    draft_pick
    |> email_data()
    |> NotificationEmail.draft_update()
    |> Mailer.deliver()
    |> Mailer.handle_delivery()
  end

  defp email_data(draft_pick) do
    %{id: id, fantasy_league_id: league_id} = draft_pick
    draft_pick = DraftPicks.get_draft_pick!(id)

    %{draft_picks: draft_picks} = DraftPicks.get_picks_for_league(league_id)
    draft_picks = DraftPickView.current_picks(draft_picks, 10)
    next_pick_index = Enum.find_index(draft_picks, &(&1.fantasy_player_id == nil))

    num_picks =
      case next_pick_index do
        nil -> 10
        num_picks -> num_picks
      end

    {last_picks, next_picks} = Enum.split(draft_picks, num_picks)

    %{
      league: draft_pick.fantasy_league,
      recipients: Accounts.get_league_and_admin_emails(league_id),
      draft_pick: draft_pick,
      last_picks: last_picks,
      next_picks: next_picks
    }
  end
end
