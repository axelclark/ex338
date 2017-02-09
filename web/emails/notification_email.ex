defmodule Ex338.NotificationEmail do
  use Phoenix.Swoosh, view: Ex338.EmailView, layout: {Ex338.LayoutView, :email}
  import Ecto.Query, only: [preload: 2]
  require Logger
  alias Ex338.{Waiver, Repo, Owner, User, Mailer}

  def draft_update(conn, league, last_picks, next_picks, owners, admins) do
    recipients = unique_recipients(owners, admins)

    new()
    |> to(recipients)
    |> from({"338 Commish", "no-reply@338admin.com"})
    |> subject(draft_headline(last_picks))
    |> render_body("draft_update.html", %{league: league, last_picks: last_picks,
                                          next_picks: next_picks, conn: conn})
  end

  defp draft_headline(last_picks) do
    last_pick = Enum.at(last_picks, 0)

    "338 Draft: #{last_pick.fantasy_team.team_name} selects #{last_pick.fantasy_player.player_name} (##{last_pick.draft_position})"
  end


  def waiver_submitted(%Waiver{id: waiver_id}) do
    waiver = get_waiver_details(waiver_id)
    owners = get_recipients(waiver.fantasy_team.fantasy_league_id)
    admins = get_admins()
    recipients = unique_recipients(owners, admins)

    new()
    |> to(recipients)
    |> from({"338 Commish", "no-reply@338admin.com"})
    |> subject(waiver_headline(waiver))
    |> render_body("waiver_submitted.html", %{waiver: waiver})
    |> Mailer.deliver
    |> handle_delivery
  end

  defp waiver_headline(%Waiver{add_fantasy_player_id: nil,
                               drop_fantasy_player: player} = waiver) do
    "338 Waiver: #{waiver.fantasy_team.team_name} drops #{player.player_name} (#{player.sports_league.abbrev})"
  end

  defp waiver_headline(%Waiver{add_fantasy_player: player} = waiver) do
    "338 Waiver: #{waiver.fantasy_team.team_name} claims #{player.player_name} (#{player.sports_league.abbrev})"
  end

  defp get_recipients(league_id) do
    Owner
    |> Owner.email_recipients_for_league(league_id)
    |> Repo.all
  end

  defp get_admins do
    Repo.all(User.admin_emails)
  end

  def unique_recipients(owners, admins) do
    Enum.uniq(owners ++ admins)
  end

  defp get_waiver_details(waiver_id) do
    Waiver
    |> preload([:fantasy_team, [add_fantasy_player: :sports_league],
               [drop_fantasy_player: :sports_league]])
    |> Repo.get(waiver_id)
  end

  defp handle_delivery({:ok, _result}) do
    Logger.info "Sent email notification for waiver"
  end

  defp handle_delivery({:error, {_, reason}}) do
    Logger.error "Email failed to send: #{reason}"
  end
end
