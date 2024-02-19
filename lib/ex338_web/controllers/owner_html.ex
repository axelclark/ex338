defmodule Ex338Web.OwnerHTML do
  use Ex338Web, :html

  def index(assigns) do
    ~H"""
    <.page_header class="sm:mb-6">
      League Owners
    </.page_header>

    <.legacy_table>
      <thead>
        <tr>
          <.legacy_th>
            Fantasy Team
          </.legacy_th>
          <.legacy_th>
            Owner
          </.legacy_th>
          <.legacy_th>
            Slack Name
          </.legacy_th>
        </tr>
      </thead>
      <tbody class="bg-white">
        <%= for owner <- @owners do %>
          <tr>
            <.legacy_td class="text-indigo-700">
              <%= fantasy_team_link(@conn, owner.fantasy_team) %>
            </.legacy_td>
            <.legacy_td class="text-indigo-700">
              <.link href={~p"/users/#{owner.user.id}"}>
                <%= owner.user.name %>
              </.link>
            </.legacy_td>
            <.legacy_td>
              <%= if owner.user.slack_name == "" do %>
                --
              <% else %>
                <%= owner.user.slack_name %>
              <% end %>
            </.legacy_td>
          </tr>
        <% end %>
      </tbody>
    </.legacy_table>
    """
  end
end
