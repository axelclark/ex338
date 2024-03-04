defmodule Ex338Web.DraftPickNotifier do
  @moduledoc false
  use Ex338Web, :html

  alias Ex338.Accounts
  alias Ex338.DraftPicks
  alias Ex338.DraftPicks.DraftPick
  alias Ex338.FantasyPlayers
  alias Ex338Web.DraftPickHTML
  alias Ex338Web.Mailer

  def send_error(changeset) do
    assigns = get_error_email_data(changeset)

    recipients = assigns.recipients
    subject = "There was an error with your autodraft queue"

    email_body = ~H"""
    <p>There was an error attempting to draft <%= @fantasy_player_name %>:</p>

    <p><%= @error_message %></p>

    <p>
      Please visit the draft page and manually draft another player.  If you think the error is incorrect, contact the commish.
    </p>
    """

    Mailer.build_and_deliver(recipients, subject, email_body)
  end

  defp get_error_email_data(changeset) do
    %{data: draft_pick, changes: %{fantasy_player_id: fantasy_player_id}} = changeset

    fantasy_player = FantasyPlayers.get_player!(fantasy_player_id)

    %{
      recipients: Accounts.get_team_and_admin_emails(draft_pick.fantasy_team_id),
      error_message: changeset_error_to_string(changeset),
      fantasy_player_name: fantasy_player.player_name
    }
  end

  defp changeset_error_to_string(changeset) do
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

  def send_update(%DraftPick{} = draft_pick) do
    assigns = get_update_email_data(draft_pick)
    recipients = assigns.recipients
    subject = draft_headline(assigns.draft_pick, assigns.league)

    email_body = ~H"""
    <p>
      <%= @draft_pick.fantasy_team.team_name %> selected <%= @draft_pick.fantasy_player.player_name %>!
    </p>

    <p>
      Visit the <%= @league.fantasy_league_name %>
      <.link href={Ex338Web.Endpoint.url() <> "/fantasy_leagues/#{@league.id}/draft_picks"}>
        draft page
      </.link>
      to see all picks or make your pick.
    </p>

    <h3>Latest Picks:</h3>
    <.draft_table draft_picks={@last_picks} />
    <h3>Next Up:</h3>
    <.draft_table draft_picks={@next_picks} />
    """

    Mailer.build_and_deliver(recipients, subject, email_body)
  end

  defp draft_headline(draft_pick, league) do
    "338 Draft - #{league.fantasy_league_name}: #{draft_pick.fantasy_team.team_name} selects #{draft_pick.fantasy_player.player_name} (##{draft_pick.draft_position})"
  end

  ## send_update

  defp get_update_email_data(draft_pick) do
    %{id: id, fantasy_league_id: league_id} = draft_pick
    draft_pick = DraftPicks.get_draft_pick!(id)

    %{draft_picks: draft_picks} = DraftPicks.get_picks_for_league(league_id)
    draft_picks = DraftPickHTML.current_picks(draft_picks, 10)
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

  defp draft_table(assigns) do
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
            <td><%= draft_pick.draft_position %></td>
            <td>
              <%= if draft_pick.fantasy_team,
                do: draft_pick.fantasy_team.team_name %>
            </td>
            <td>
              <%= if draft_pick.fantasy_player,
                do: draft_pick.fantasy_player.player_name %>
            </td>
            <td>
              <%= if draft_pick.fantasy_player,
                do: draft_pick.fantasy_player.sports_league.abbrev %>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end
end
