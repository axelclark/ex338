defmodule Ex338Web.WaiverNotifier do
  @moduledoc false
  use Ex338Web, :html

  import Ex338Web.WaiverHTML, only: [display_name: 1]

  alias Ex338.Accounts
  alias Ex338.Waivers
  alias Ex338.Waivers.Waiver
  alias Ex338Web.Mailer

  def waiver_submitted(%Waiver{id: waiver_id}) do
    waiver = Waivers.find_waiver(waiver_id)
    fantasy_league = waiver.fantasy_team.fantasy_league
    recipients = Accounts.get_league_and_admin_emails(fantasy_league.id)
    subject = waiver_headline(waiver, fantasy_league)

    assigns = %{waiver: waiver}

    email_body = ~H"""
    <h3><%= @waiver.fantasy_team.team_name %> submitted a new waiver</h3>
    <p>
      <%= @waiver.fantasy_team.team_name %>'s current waiver position in <%= @waiver.fantasy_team.fantasy_league.fantasy_league_name %> is #<%= @waiver.fantasy_team.waiver_position %>.
    </p>
    <%= if @waiver.add_fantasy_player do %>
      <p>
        <strong>Player to add: </strong><%= display_name(@waiver.add_fantasy_player) %> (<%= @waiver.add_fantasy_player.sports_league.abbrev %>)
      </p>
    <% end %>
    <%= if @waiver.drop_fantasy_player do %>
      <p>
        <strong>Player to drop: </strong><%= @waiver.drop_fantasy_player.player_name %>(<%= @waiver.drop_fantasy_player.sports_league.abbrev %>)
      </p>
    <% end %>

    <%= if @waiver.add_fantasy_player do %>
      <p>
        The waiver period for the added player closes <%= short_datetime_pst(@waiver.process_at) %> (PST/PDT).
      </p>
    <% end %>
    ...
    """

    Mailer.build_and_deliver(recipients, subject, email_body)
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
