defmodule Ex338Web.NotificationEmail do
  @moduledoc false

  use Phoenix.Swoosh, view: Ex338Web.EmailView, layout: {Ex338Web.LayoutView, :email}
  import Ex338Web.WaiverView, only: [display_name: 1]
  require Logger
  alias Ex338.{Accounts, Waivers, Waivers.Waiver}
  alias Ex338Web.{Mailer}

  def draft_update(%{
        recipients: recipients,
        league: league,
        draft_pick: draft_pick,
        last_picks: last_picks,
        next_picks: next_picks
      }) do
    new()
    |> to(recipients)
    |> from(Mailer.default_from_name_and_email())
    |> subject(draft_headline(draft_pick, league))
    |> render_body("draft_update.html", %{
      league: league,
      draft_pick: draft_pick,
      last_picks: last_picks,
      next_picks: next_picks
    })
  end

  defp draft_headline(draft_pick, league) do
    "338 Draft - #{league.fantasy_league_name}: #{draft_pick.fantasy_team.team_name} selects #{draft_pick.fantasy_player.player_name} (##{draft_pick.draft_position})"
  end

  def draft_error(email_data) do
    new()
    |> to(email_data.recipients)
    |> from(Mailer.default_from_name_and_email())
    |> subject("There was an error with your autodraft queue")
    |> render_body("draft_error.html", email_data)
  end

  def in_season_draft_update(
        %{recipients: recipients, pick: pick, fantasy_league: fantasy_league} = email_data
      ) do
    new()
    |> to(recipients)
    |> from(Mailer.default_from_name_and_email())
    |> subject(in_season_draft_headline(pick, fantasy_league))
    |> render_body("in_season_draft_update.html", email_data)
  end

  defp in_season_draft_headline(pick, fantasy_league) do
    fantasy_team = pick.draft_pick_asset.fantasy_team

    "338 Draft - #{fantasy_league.fantasy_league_name}: #{fantasy_team.team_name} selects #{pick.drafted_player.player_name} (##{pick.position})"
  end

  def waiver_submitted(%Waiver{id: waiver_id}) do
    waiver = Waivers.find_waiver(waiver_id)
    fantasy_league = waiver.fantasy_team.fantasy_league
    recipients = Accounts.get_league_and_admin_emails(fantasy_league.id)

    new()
    |> to(recipients)
    |> from(Mailer.default_from_name_and_email())
    |> subject(waiver_headline(waiver, fantasy_league))
    |> render_body("waiver_submitted.html", %{waiver: waiver})
    |> Mailer.deliver()
    |> Mailer.handle_delivery()
  end

  defp waiver_headline(
         %Waiver{add_fantasy_player_id: nil, drop_fantasy_player: player} = waiver,
         fantasy_league
       ) do
    "338 Waiver - #{fantasy_league.fantasy_league_name}: #{waiver.fantasy_team.team_name} drops #{player.player_name} (#{player.sports_league.abbrev})"
  end

  defp waiver_headline(%Waiver{add_fantasy_player: player} = waiver, fantasy_league) do
    "338 Waiver - #{fantasy_league.fantasy_league_name}: #{waiver.fantasy_team.team_name} claims #{display_name(player)} (#{player.sports_league.abbrev})"
  end
end
