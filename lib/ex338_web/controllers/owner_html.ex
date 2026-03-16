defmodule Ex338Web.OwnerHTML do
  use Ex338Web, :html

  def index(assigns) do
    ~H"""
    <div class="space-y-4">
      <div class="space-y-1">
        <p class="text-sm text-muted-foreground">League directory</p>
        <.page_header>League Owners</.page_header>
      </div>

      <div class="rounded-lg border bg-card shadow-xs overflow-hidden">
        <div class="overflow-x-auto">
          <.legacy_table class="min-w-full">
            <thead>
              <tr>
                <.legacy_th>Fantasy Team</.legacy_th>
                <.legacy_th>Owner</.legacy_th>
                <.legacy_th>Slack Name</.legacy_th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= if @owners == [] do %>
                <tr>
                  <td
                    colspan="3"
                    class="px-4 py-6 border-b border-gray-200 text-center text-sm text-muted-foreground"
                  >
                    No owners found for this league.
                  </td>
                </tr>
              <% else %>
                <%= for owner <- @owners do %>
                  <tr>
                    <.legacy_td class="text-indigo-700">
                      <.fantasy_team_name_link fantasy_team={owner.fantasy_team} />
                    </.legacy_td>
                    <.legacy_td class="text-indigo-700">
                      <.link href={~p"/users/#{owner.user.id}"}>
                        {owner.user.name}
                      </.link>
                    </.legacy_td>
                    <.legacy_td>
                      <%= if owner.user.slack_name == "" do %>
                        --
                      <% else %>
                        {owner.user.slack_name}
                      <% end %>
                    </.legacy_td>
                  </tr>
                <% end %>
              <% end %>
            </tbody>
          </.legacy_table>
        </div>
      </div>
    </div>
    """
  end
end
