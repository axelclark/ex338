defmodule Ex338Web.NotificationEmail do
  @moduledoc false

  use Phoenix.Swoosh, view: Ex338Web.EmailView, layout: {Ex338Web.LayoutView, :email}
  import Ecto.Query, only: [preload: 2]
  import Ex338Web.WaiverView, only: [display_name: 1]
  require Logger
  alias Ex338.{Waiver, Repo, User}
  alias Ex338Web.{Mailer}

  @commish {"338 Commish", "no-reply@338admin.com"}

  def draft_update(conn, league, last_picks, next_picks, recipients) do
    new()
    |> to(recipients)
    |> from(@commish)
    |> subject(draft_headline(last_picks))
    |> render_body("draft_update.html", %{league: league, last_picks: last_picks,
                                          next_picks: next_picks, conn: conn})
  end

  defp draft_headline(last_picks) do
    last_pick = Enum.at(last_picks, 0)

    "338 Draft: #{last_pick.fantasy_team.team_name} selects #{last_pick.fantasy_player.player_name} (##{last_pick.draft_position})"
  end

  def in_season_draft_update(
    %{recipients: recipients, last_picks: last_picks} = email_data) do

    new()
    |> to(recipients)
    |> from(@commish)
    |> subject(in_season_draft_headline(last_picks))
    |> render_body("in_season_draft_update.html", email_data)
  end

  defp in_season_draft_headline(last_picks) do
    last_pick = Enum.at(last_picks, 0)

    "338 Draft: #{last_pick.draft_pick_asset.fantasy_team.team_name} selects #{last_pick.drafted_player.player_name} (##{last_pick.position})"
  end

  def waiver_submitted(%Waiver{id: waiver_id}) do
    waiver = get_waiver_details(waiver_id)
    league_id = waiver.fantasy_team.fantasy_league_id
    recipients = User.Store.get_league_and_admin_emails(league_id)

    new()
    |> to(recipients)
    |> from(@commish)
    |> subject(waiver_headline(waiver))
    |> render_body("waiver_submitted.html", %{waiver: waiver})
    |> Mailer.deliver
    |> Mailer.handle_delivery
  end

  defp waiver_headline(%Waiver{add_fantasy_player_id: nil,
                               drop_fantasy_player: player} = waiver) do
    "338 Waiver: #{waiver.fantasy_team.team_name} drops #{player.player_name} (#{player.sports_league.abbrev})"
  end

  defp waiver_headline(%Waiver{add_fantasy_player: player} = waiver) do
    "338 Waiver: #{waiver.fantasy_team.team_name} claims #{display_name(player)} (#{player.sports_league.abbrev})"
  end

  defp get_waiver_details(waiver_id) do
    Waiver
    |> preload([:fantasy_team, [add_fantasy_player: :sports_league],
               [drop_fantasy_player: :sports_league]])
    |> Repo.get(waiver_id)
  end
end
