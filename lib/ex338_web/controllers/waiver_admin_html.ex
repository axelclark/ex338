defmodule Ex338Web.WaiverAdminHTML do
  use Ex338Web, :html

  def edit(assigns) do
    ~H"""
    <.two_col_form :let={f} for={@changeset} action={~p"/waiver_admin/#{@waiver}"}>
      <:title>
        Process Waiver
      </:title>
      <:description>
        {@waiver.fantasy_team.team_name}'s current waiver position is {@waiver.fantasy_team.waiver_position}.
      </:description>

      <p class="mb-4 font-medium text-gray-700 leading-5">
        Add Fantasy Player:
        <%= if @waiver.add_fantasy_player do %>
          {@waiver.add_fantasy_player.player_name}
        <% else %>
          None
        <% end %>
      </p>

      <p class="mb-4 font-medium text-gray-700 leading-5">
        Drop Fantasy Player:
        <%= if @waiver.drop_fantasy_player do %>
          {@waiver.drop_fantasy_player.player_name}
        <% else %>
          None
        <% end %>
      </p>

      <.input
        field={f[:status]}
        label="Select status for the waiver"
        type="select"
        options={Ex338.Waivers.Waiver.status_options()}
      />
      <:actions>
        <.submit_buttons back_route={~p"/fantasy_leagues/#{@fantasy_league}/waivers"} />
      </:actions>
    </.two_col_form>
    """
  end
end
