defmodule Ex338Web.InSeasonDraftPickNotifier do
  @moduledoc false
  use Ex338Web, :html

  alias Ex338.Accounts
  alias Ex338.FantasyLeagues
  alias Ex338.InSeasonDraftPicks
  alias Ex338.InSeasonDraftPicks.InSeasonDraftPick
  alias Ex338.Slack
  alias Ex338Web.Mailer

  def send_update(%InSeasonDraftPick{} = pick) do
    num_picks = 5

    assigns = in_season_draft_email_data(pick, num_picks)
    recipients = assigns.recipients
    subject = in_season_draft_headline(assigns.pick, assigns.fantasy_league)

    email_body = ~H"""
    <p>
      {@pick.draft_pick_asset.fantasy_team.team_name} selected {@pick.drafted_player.player_name}!
      <%= if @next_pick do %>
        Next up is {@next_pick.draft_pick_asset.fantasy_team.team_name}.
      <% else %>
        That wraps up the draft!
      <% end %>
    </p>

    <p>
      Visit the {@pick.championship.title}
      <.link href={Ex338Web.Endpoint.url() <>
            "/fantasy_leagues/#{@fantasy_league.id}/championships/#{@pick.championship_id}"}>
        draft page
      </.link>
      to see all picks or make your pick.
    </p>

    <h3>Latest Picks:</h3>
    <.in_season_draft_table draft_picks={@last_picks} />
    <h3>Next Up:</h3>
    <.in_season_draft_table draft_picks={@next_picks} />
    """

    email_result = Mailer.build_and_deliver(recipients, subject, email_body)

    Slack.notify_league(assigns.fantasy_league, update_slack_message(assigns))

    email_result
  end

  # Kept terse for the same reason as the redraft alert: the channel is already
  # the record of what's been picked.
  defp update_slack_message(assigns) do
    %{fantasy_league: fantasy_league, next_pick: next_pick, pick: pick} = assigns
    player = pick.drafted_player

    """
    *#{Slack.escape(pick.draft_pick_asset.fantasy_team.team_name)} selected #{Slack.escape(player.player_name)} (#{Slack.escape(player.sports_league.abbrev)})* — pick ##{pick.position}
    #{on_the_clock(next_pick)} #{slack_draft_link(fantasy_league, pick)}
    """
  end

  defp on_the_clock(nil), do: "That wraps up the draft!"

  defp on_the_clock(next_pick) do
    "On the clock: #{Slack.escape(next_pick.draft_pick_asset.fantasy_team.team_name)}."
  end

  defp slack_draft_link(fantasy_league, pick) do
    url =
      Ex338Web.Endpoint.url() <>
        "/fantasy_leagues/#{fantasy_league.id}/championships/#{pick.championship_id}"

    Slack.link(url, "#{pick.championship.title} draft page")
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

  defp in_season_draft_headline(pick, fantasy_league) do
    fantasy_team = pick.draft_pick_asset.fantasy_team

    "338 Draft - #{fantasy_league.fantasy_league_name}: #{fantasy_team.team_name} selects #{pick.drafted_player.player_name} (##{pick.position})"
  end

  defp in_season_draft_table(assigns) do
    ~H"""
    <table>
      <thead>
        <tr>
          <th>Draft Position</th>
          <th>Fantasy Team</th>
          <th>Fantasy Player</th>
          <th>Sports League</th>
        </tr>
      </thead>
      <tbody>
        <%= for draft_pick <- @draft_picks do %>
          <tr>
            <td>{draft_pick.position}</td>
            <td>{draft_pick.draft_pick_asset.fantasy_team.team_name}</td>
            <td>
              {if draft_pick.drafted_player,
                do: draft_pick.drafted_player.player_name}
            </td>
            <td>
              {if draft_pick.drafted_player,
                do: draft_pick.drafted_player.sports_league.abbrev}
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end
