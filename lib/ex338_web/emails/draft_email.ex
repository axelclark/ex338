defmodule Ex338Web.DraftEmail do
  @moduledoc false

  alias Ex338.Accounts
  alias Ex338.DraftPicks
  alias Ex338.DraftPicks.DraftPick
  alias Ex338.FantasyPlayers
  alias Ex338Web.DraftPickView
  alias Ex338Web.Mailer
  alias Ex338Web.NotificationEmail

  require Logger

  def send_error(changeset) do
    changeset
    |> get_error_email_data()
    |> NotificationEmail.draft_error()
    |> Mailer.deliver()
    |> Mailer.handle_delivery()
  end

  def send_update(%DraftPick{} = draft_pick) do
    draft_pick
    |> get_update_email_data()
    |> NotificationEmail.draft_update()
    |> Mailer.deliver()
    |> Mailer.handle_delivery()
  end

  ## send_error

  defp get_error_email_data(changeset) do
    %{data: draft_pick, changes: %{fantasy_player_id: fantasy_player_id}} = changeset

    fantasy_player = FantasyPlayers.get_player!(fantasy_player_id)

    %{
      recipients: Accounts.get_team_and_admin_emails(draft_pick.fantasy_team_id),
      error_message: changeset_error_to_string(changeset),
      fantasy_player_name: fantasy_player.player_name
    }
  end

  def changeset_error_to_string(changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
    |> Enum.reduce("", fn {_k, v}, acc ->
      joined_errors = Enum.join(v, "; ")
      "#{acc}#{joined_errors} "
    end)
  end

  ## send_update

  defp get_update_email_data(draft_pick) do
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
