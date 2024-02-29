defmodule Ex338Web.InjuredReserveHTML do
  use Ex338Web, :html

  def index(assigns) do
    ~H"""
    <.page_header class="sm:mb-6">
      Injured Reserve Actions
    </.page_header>

    <div class="flex flex-col">
      <div class="py-2 -my-2 overflow-x-auto sm:-mx-6 sm:px-6 lg:-mx-8 lg:px-8">
        <div class="inline-block min-w-full overflow-hidden align-middle border-b border-gray-200 shadow sm:rounded-lg">
          <.legacy_table class="min-w-full">
            <thead>
              <tr>
                <.legacy_th>
                  Submitted*
                </.legacy_th>
                <.legacy_th>
                  Team
                </.legacy_th>
                <.legacy_th>
                  Injured Player
                </.legacy_th>
                <.legacy_th>
                  Replacement Player
                </.legacy_th>
                <.legacy_th>
                  Status
                </.legacy_th>
              </tr>
            </thead>
            <tbody class="bg-white">
              <%= if @injured_reserves == [] do %>
                <tr>
                  <.legacy_td>
                    --
                  </.legacy_td>
                  <.legacy_td></.legacy_td>
                  <.legacy_td></.legacy_td>
                  <.legacy_td></.legacy_td>
                  <.legacy_td></.legacy_td>
                </tr>
              <% else %>
                <%= for injured_reserve <- @injured_reserves do %>
                  <tr>
                    <.legacy_td>
                      <%= short_datetime_pst(injured_reserve.inserted_at) %>
                    </.legacy_td>
                    <.legacy_td>
                      <.fantasy_team_name_link fantasy_team={injured_reserve.fantasy_team} />
                    </.legacy_td>
                    <.legacy_td>
                      <%= injured_reserve.injured_player.player_name %> (<%= injured_reserve.injured_player.sports_league.abbrev %>)
                    </.legacy_td>
                    <.legacy_td>
                      <%= injured_reserve.replacement_player.player_name %> (<%= injured_reserve.replacement_player.sports_league.abbrev %>)
                    </.legacy_td>
                    <.legacy_td>
                      <%= if display_admin_buttons?(@current_user, injured_reserve) do %>
                        <.admin_buttons
                          fantasy_league={@fantasy_league}
                          injured_reserve={injured_reserve}
                        />
                      <% else %>
                        <%= display_status(injured_reserve) %>
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

    <p class="pl-4 mt-1 text-sm font-medium text-gray-700 leading-5 sm:mt-2 sm:pl-6">
      * All dates and times are in Pacific Standard Time (PST)/Pacific Daylight Time (PDT).
    </p>
    """
  end

  def display_admin_buttons?(current_user, injured_reserve) do
    with true <- current_user && current_user.admin do
      for_admin_action?(injured_reserve)
    end
  end

  defp for_admin_action?(injured_reserve) do
    %{status: status} = injured_reserve

    status == :submitted ||
      status == :approved
  end

  attr :fantasy_league, :map, required: true
  attr :injured_reserve, :map, required: true

  defp admin_buttons(%{injured_reserve: %{status: :submitted}} = assigns) do
    ~H"""
    <.link
      patch={
        ~p"/fantasy_leagues/#{@fantasy_league.id}/injured_reserves/#{@injured_reserve.id}?#{%{"injured_reserve" => %{"status" => "approved"}}}"
      }
      method="patch"
      data-confirm="Please confirm to approve IR"
      class="inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-indigo-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
    >
      Approve
    </.link>

    <.link
      patch={
        ~p"/fantasy_leagues/#{@fantasy_league.id}/injured_reserves/#{@injured_reserve.id}?#{%{"injured_reserve" => %{"status" => "rejected"}}}"
      }
      method="patch"
      data-confirm="Please confirm to reject IR"
      class="inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-indigo-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
    >
      Reject
    </.link>
    """
  end

  defp admin_buttons(%{injured_reserve: %{status: :approved}} = assigns) do
    ~H"""
    <.link
      patch={
        ~p"/fantasy_leagues/#{@fantasy_league.id}/injured_reserves/#{@injured_reserve.id}?#{%{"injured_reserve" => %{"status" => "returned"}}}"
      }
      method="patch"
      data-confirm="Please confirm to return IR"
      class="inline-flex items-center px-2.5 py-1.5 border border-gray-300 text-xs leading-4 font-medium rounded text-indigo-700 bg-white hover:text-gray-500 focus:outline-none focus:border-blue-300 focus:shadow-outline-blue active:text-gray-800 active:bg-gray-50 transition ease-in-out duration-150"
    >
      Return
    </.link>
    """
  end

  defp display_status(injured_reserve) do
    Phoenix.Naming.humanize(injured_reserve.status)
  end

  def new(assigns) do
    ~H"""
    <.two_col_form
      :let={f}
      for={@changeset}
      action={~p"/fantasy_teams/#{@fantasy_team.id}/injured_reserves"}
    >
      <:title>
        Submit a new Injured Reserve for <%= @fantasy_team.team_name %>
      </:title>
      <:description>
        Submit an new injured reserve for commish approval. Injured player
        will be moved to IR and replacement_player will be added to roster.
      </:description>

      <.input
        field={f[:injured_player_id]}
        type="select"
        label="Injured Player"
        prompt="Select a player to move to IR"
        options={format_players_for_select(@owned_players)}
      />
      <.input
        field={f[:sports_league]}
        type="select"
        label="Sports League"
        prompt="Select sport to filter players"
        options={sports_abbrevs(@avail_players)}
        class="sports-select-filter"
      />
      <.input
        field={f[:replacement_player_id]}
        type="select"
        label="Replacement player"
        prompt="Select replacement player"
        options={format_players_for_select(@avail_players)}
        class="players-to-filter"
      />
      <:actions>
        <.submit_buttons back_route={~p"/fantasy_teams/#{@fantasy_team}"} />
      </:actions>
    </.two_col_form>
    """
  end
end
