defmodule Ex338Web.TradeNotifier do
  @moduledoc false
  use Ex338Web, :html

  alias Ex338Web.Mailer

  def cancel(league, trade, recipients, fantasy_team) do
    subject = "#{fantasy_team.team_name} canceled its proposed 338 trade"
    assigns = %{fantasy_team: fantasy_team, league: league, trade: trade}

    email_body = ~H"""
    <h3><%= @fantasy_team.team_name %> canceled its proposed trade</h3>
    <.trade_table trade={@trade} />
    <h3>Additional Terms:</h3>
    <p>
      <%= if @trade.additional_terms do %>
        <%= @trade.additional_terms %>
      <% else %>
        None
      <% end %>
    </p>
    ...
    """

    Mailer.build_and_deliver(recipients, subject, email_body)
  end

  def pending(league, trade, recipients) do
    subject = "New 338 #{league.fantasy_league_name} Trade for Approval"
    assigns = %{league: league, trade: trade}

    email_body = ~H"""
    <h3>The following trade is submitted for <%= @league.fantasy_league_name %> League approval:</h3>
    <.trade_table trade={@trade} />
    <h3>Additional Terms:</h3>
    <p>
      <%= if @trade.additional_terms do %>
        <%= @trade.additional_terms %>
      <% else %>
        None
      <% end %>
    </p>
    <br />
    <p>
      There will be a 3-day voting period for the league to approve the trade. A
      no-response during the voting period will be considered an approval.
    </p>
    <h3>
      Please go to the
      <.link href={url(~p"/fantasy_leagues/#{@league.id}/trades")}>list of trades</.link>
      to place your vote.
    </h3>
    ...
    """

    Mailer.build_and_deliver(recipients, subject, email_body)
  end

  def propose(league, trade, recipients) do
    subject = "#{trade.submitted_by_team.team_name} proposed a 338 trade"
    assigns = %{league: league, trade: trade}

    email_body = ~H"""
    <h3><%= @trade.submitted_by_team.team_name %> proposed the following trade:</h3>
    <.trade_table trade={@trade} />
    <h3>Additional Terms:</h3>
    <p>
      <%= if @trade.additional_terms do %>
        <%= @trade.additional_terms %>
      <% else %>
        None
      <% end %>
    </p>
    <br />
    <h3>Instructions to Accept or Reject the proposed trade:</h3>
    <p>
      All participating teams must accept the trade before it is submitted to the league for approval. A "yes" vote will accept
      the trade on behalf of your team.  A "no" vote will reject the trade on behalf of your team.
    </p>
    <p>
      Please go to the
      <.link href={url(~p"/fantasy_leagues/#{@league.id}/trades")}>list of proposed trades</.link>
      to accept or reject the trade.
    </p>
    ...
    """

    Mailer.build_and_deliver(recipients, subject, email_body)
  end

  def reject(league, trade, recipients, fantasy_team) do
    subject = "Proposed trade rejected by #{fantasy_team.team_name}"
    assigns = %{fantasy_team: fantasy_team, league: league, trade: trade}

    email_body = ~H"""
    <h3>
      <%= @fantasy_team.team_name %> rejected the trade proposed by <%= @trade.submitted_by_team.team_name %>
    </h3>
    <.trade_table trade={@trade} />
    <h3>Additional Terms:</h3>
    <p>
      <%= if @trade.additional_terms do %>
        <%= @trade.additional_terms %>
      <% else %>
        None
      <% end %>
    </p>
    ...
    """

    Mailer.build_and_deliver(recipients, subject, email_body)
  end

  defp trade_table(assigns) do
    ~H"""
    <table>
      <thead>
        <tr>
          <th>Gaining Team</th>
          <th>Fantasy Player/Future Pick</th>
          <th>Losing Team</th>
        </tr>
      </thead>
      <tbody>
        <%= for line_item <- @trade.trade_line_items do %>
          <tr>
            <td>
              <%= line_item.gaining_team.team_name %>
            </td>
            <td>
              <%= if(line_item.fantasy_player) do %>
                <%= display_player(line_item.fantasy_player) %>
              <% else %>
                <%= display_future_pick(line_item.future_pick) %>
              <% end %>
            </td>
            <td>
              <%= line_item.losing_team.team_name %>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def display_player(%{player_name: name, sports_league: %{abbrev: abbrev}}),
    do: "#{String.trim(name)}, #{abbrev}"
end
